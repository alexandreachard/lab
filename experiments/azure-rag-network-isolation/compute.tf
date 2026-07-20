#
## AppService
#
resource "azurerm_service_plan" "main" {
  location               = var.location
  resource_group_name    = azurerm_resource_group.main.name
  name                   = local.resource_names.asp
  os_type                = var.asp_os_type
  sku_name               = var.asp_sku_name
  tags                   = var.tags
  zone_balancing_enabled = var.asp_zone_balancing
}

resource "azurerm_linux_web_app" "main" {
  for_each              = local.app_configs
  name                  = each.value.name
  resource_group_name   = azurerm_resource_group.main.name
  location              = var.location
  service_plan_id       = azurerm_service_plan.main.id
  tags                  = var.tags
  https_only            = var.https_only
  public_network_access_enabled = var.public_network_access_enabled
  virtual_network_subnet_id     = module.network.appservice_subnet_id
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false


  app_settings = merge(
    each.value.base_settings,
    
    each.key == "api" ? {
      AZURE_COSMOSDB_ACCOUNT                = azurerm_cosmosdb_account.main.endpoint
      AZURE_COSMOSDB_KEY                    = azurerm_cosmosdb_account.main.primary_key
      AZURE_COSMOSDB_NAME                   = azurerm_cosmosdb_sql_database.main.name
      AZURE_OPENAI_ENDPOINT                 = azurerm_cognitive_account.main["Open_AI"].endpoint
      AZURE_OPENAI_KEY                      = azurerm_cognitive_account.main["Open_AI"].primary_access_key
      AZURE_SEARCH_ADMIN_KEY                = azurerm_search_service.main.primary_key
      AZURE_SEARCH_BACKUP_ADMIN_KEY         = azurerm_search_service.backup.primary_key
      AZURE_SEARCH_INDEX                    = local.resource_names.azure_search_index
      AZURE_SEARCH_SERVICE_ENDPOINT         = "https://${azurerm_search_service.main.name}.search.windows.net"
      AZURE_SEARCH_BACKUP_SERVICE_ENDPOINT  = "https://${azurerm_search_service.backup.name}.search.windows.net"
      AZURE_STORAGE_CONNECTION_STRING       = azurerm_storage_account.main.primary_connection_string
      AZURE_STORAGE_CONTAINER_NAME          = azurerm_storage_container.main.name
      AZURE_DOCUMENT_INTELLIGENCE_ENDPOINT  = azurerm_cognitive_account.main["Document_Intelligence"].endpoint
      AZURE_DOCUMENT_INTELLIGENCE_KEY       = azurerm_cognitive_account.main["Document_Intelligence"].primary_access_key
      TOKEN_AUD                             = var.client_id
      APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.webapp_insights.connection_string
    } : {},

    each.key == "front" ? {
      AUTHENTICATION_CLIENT_ID     = var.client_id
      AUTHENTICATION_REDIRECT_URI  = "https://rag-${local.environment_code}-${each.value.suffix}.azurewebsites.net/"
      BACKEND_API_URL              = "https://rag-${local.environment_code}-web-api.azurewebsites.net"
      STATISTICS_GROUP_ID          = "Platform-Metrics-${local.environment_code}-Reporting"
      STATISTICS_DOWNLOAD_GROUP_ID = "Platform-Metrics-${local.environment_code}-Downloads"
      APP_INSIGHTS_ID              = azurerm_application_insights.webapp_insights.app_id
    } : {}
  )

  site_config {
    always_on           = var.always_on
    ftps_state          = var.ftps_state
    minimum_tls_version = "1.2"
    application_stack {
      docker_image_name   = each.value.docker_image_name
      docker_registry_url = "https://${each.value.registry_name}.azurecr.io"
    }
    container_registry_use_managed_identity = true
    cors {
      allowed_origins = ["*"]
    }
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  for_each             = local.app_configs
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.main[each.key].identity[0].principal_id
}

resource "azurerm_service_plan" "plan" {
  name                = local.resource_names.functionapp-asp
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = var.asp_os_type
  sku_name            = "EP2"
}

#
## Function App
#
resource "azurerm_linux_function_app" "function" {
  name                                           = local.resource_names.functionapp
  resource_group_name                            = azurerm_resource_group.main.name
  location                                       = azurerm_resource_group.main.location
  service_plan_id                                = azurerm_service_plan.plan.id
  storage_account_name                           = azurerm_storage_account.main.name
  storage_account_access_key                     = azurerm_storage_account.main.primary_access_key
  https_only                                     = var.https_only
  virtual_network_subnet_id                      = module.network.function_subnet_id
  ftp_publish_basic_authentication_enabled       = false
  webdeploy_publish_basic_authentication_enabled = false
  identity {
    type = "SystemAssigned"
  }

  site_config {
    container_registry_use_managed_identity = true
    minimum_tls_version                     = "1.2"
    application_stack {
      docker {
        registry_url = azurerm_container_registry.main.login_server
        image_name   = "deployimage" 
        image_tag    = "latest"
      }
    }
  }

  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.function_insights.connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "AZURE_OPENAI_ENDPOINT"                      = azurerm_cognitive_account.main["Open_AI"].endpoint
    "AZURE_OPENAI_KEY"                           = azurerm_cognitive_account.main["Open_AI"].primary_access_key
    "AZURE_OPENAI_API_VERSION"                   = var.azure_openai_api_version
    "AZURE_OPENAI_EMBEDDING_DEPLOYMENT_NAME"     = var.azure_openai_embedding_deployment_name
    "AZURE_OPENAI_EMBEDDING_DIMENSIONS"          = var.azure_openai_embedding_dimensions
    "AZURE_OPENAI_MODEL_DEPLOYMENT_NAME"         = var.azure_openai_model_deployment_name
    "AZURE_STORAGE_CONNECTION_STRING"            = azurerm_storage_account.main.primary_connection_string
    "AZURE_STORAGE_CONTAINER_NAME"               = azurerm_storage_container.main.name
    "AZURE_QUEUE_NAME"                           = local.resource_names.queue_indexation
    "AZURE_TABLE_NAME"                           = local.resource_names.storage_table
    "AZURE_STORAGE_PREFIX_CREATED"               = "https://${azurerm_storage_account.main.name}.blob.core.windows.net/${local.resource_names.container}/"
    "AZURE_STORAGE_PREFIX_DELETED"               = "https://${azurerm_storage_account.main.name}.dfs.core.windows.net/${local.resource_names.container}/"
    "AZURE_SEARCH_SERVICE_ENDPOINT"              = "https://${azurerm_search_service.main.name}.search.windows.net"
    "AZURE_SEARCH_ADMIN_KEY"                     = azurerm_search_service.main.primary_key
    "AZURE_SEARCH_BACKUP_SERVICE_ENDPOINT"       = "https://${azurerm_search_service.backup.name}.search.windows.net"
    "AZURE_SEARCH_BACKUP_ADMIN_KEY"              = azurerm_search_service.backup.primary_key
    "AZURE_SEARCH_INDEX"                         = local.resource_names.azure_search_index
    "AZURE_DOCUMENT_INTELLIGENCE_ENDPOINT"       = azurerm_cognitive_account.main["Document_Intelligence"].endpoint
    "AZURE_DOCUMENT_INTELLIGENCE_KEY"            = azurerm_cognitive_account.main["Document_Intelligence"].primary_access_key
    "VISUAL_SYSTEM_PROMPT"                       = var.visual_system_prompt
    "MAX_VISUAL_TOKENS"                          = var.max_visual_tokens
    "VISUAL_TEMPERATURE"                         = var.visual_temperature
    "BUILD_FLAGS"                                = var.build_flag
    "ENABLE_ORYX_BUILD"                          = var.enable_oryx_build
    "FUNCTIONS_WORKER_RUNTIME"                   = var.FUNCTIONS_WORKER_RUNTIME
    "SCM_DO_BUILD_DURING_DEPLOYMENT"             = var.SCM_DO_BUILD_DURING_DEPLOYMENT
    "MAX_INPUT_SIZE"                             = var.MAX_INPUT_SIZE
    "MAX_OUTPUT_SIZE"                            = var.MAX_OUTPUT_SIZE
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE"        = var.WEBSITES_ENABLE_APP_SERVICE_STORAGE
    "XDG_CACHE_HOME"                             = var.XDG_CACHE_HOME
    "AZURE_OPENAI_TEMPERATURE"                   = var.AZURE_OPENAI_TEMPERATURE
  }
}

resource "azurerm_role_assignment" "functionapp_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_function_app.function.identity[0].principal_id
}

#
## ACR & Workspaces
#
resource "azurerm_container_registry" "main" {
  location               = var.location
  name                   = local.acr_name
  resource_group_name    = azurerm_resource_group.main.name
  admin_enabled          = var.acr_admin_enabled
  sku                    = var.acr_sku
  data_endpoint_enabled  = var.data_endpoint_enabled
  anonymous_pull_enabled = var.anonymous_pull_enabled
  tags                   = var.tags
}

resource "azurerm_log_analytics_workspace" "webapp_workspace" {
  name                = local.resource_names.webapp_workspace
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_application_insights" "webapp_insights" {
  name                = local.resource_names.appinsights_webapp
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.webapp_workspace.id
  tags                = var.tags
}

resource "azurerm_log_analytics_workspace" "function_workspace" {
  name                = local.resource_names.function_workspace
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_application_insights" "function_insights" {
  name                = "${local.prefix}-function-insights"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.function_workspace.id
  tags                = var.tags
}