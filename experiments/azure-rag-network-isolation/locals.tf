locals {
  environment_name = lower(var.tags["Environment"])

  environment_code = (
    lower(var.tags["Environment"]) == "production" ? "prd" :
    lower(var.tags["Environment"]) == "development" ? "dev" :
    lower(var.tags["Environment"]) == "quality" ? "qal" :
    substr(local.environment_name, 0, 3)
  )
  
  prefix = "rag-${local.environment_code}"

  resource_names = {
    resource_group        = "${local.prefix}-rg-backend"
    cosmosdb_account      = "${local.prefix}-cosmos-db"
    cosmosdb_sql_database = "${local.prefix}-cosmos-sqldb"
    search                = "${local.prefix}-srch-core"
    search-backup         = "${local.prefix}-srch-backup"
    asp                   = "${local.prefix}-webapp-asp"
    storage               = "rag${local.environment_code}stocore"
    container             = "${local.prefix}-sto-data-bucket"
    functionapp           = "${local.prefix}-functionapp"
    functionapp-asp       = "${local.prefix}-functionapp-asp"
    azure_search_index    = "${local.prefix}-idx"
    storage_table         = "IndexingLogs"
    queue_indexation      = "${local.prefix}-queue-indexation"
    appinsights_function  = "${local.prefix}-func-appinsights"
    appinsights_webapp    = "${local.prefix}-webapp-appinsights"
    webapp_workspace      = "${local.prefix}-webapp-workspace"
    function_workspace    = "${local.prefix}-function-workspace"
    vnet_name             = "${local.prefix}-vnet"
  }

  acr_name = "rag${local.environment_code}acrcore"

  # Streamlined structural map for App Services
  app_configs = {
    for key, app in var.apps : key => {
      name              = "rag-${local.environment_code}-${app.suffix}"
      registry_name     = local.acr_name
      docker_image_name = app.docker_image_name
      base_settings     = merge({ AUTHENTICATION_TENANT_ID = var.tenant_id }, app.app_settings)
    }
  }

  cognitive_account_name = { for k, v in var.cognitive_accounts : k => "rag-${local.environment_code}-cog-${v.cdn_suffix}" }
  cognitive_account_cdn  = { for k, v in var.cognitive_accounts : k => "rag-${local.environment_code}-${v.cdn_suffix}" }

  private_services = {
    blob          = { zone_name = "privatelink.blob.core.windows.net", subresource_names = ["blob"], private_endpoint_name = "pe-blob" }
    acr           = { zone_name = "privatelink.azurecr.io", subresource_names = ["registry"], private_endpoint_name = "pe-acr" }
    formrecog     = { zone_name = "privatelink.cognitiveservices.azure.com", subresource_names = ["account"], private_endpoint_name = "pe-formrecog" }
    search        = { zone_name = "privatelink.search.windows.net", subresource_names = ["searchService"], private_endpoint_name = "pe-search" }
    search-backup = { zone_name = "privatelink.search.windows.net", subresource_names = ["searchService"], private_endpoint_name = "pe-search-backup" }
    cosmosdb      = { zone_name = "privatelink.documents.azure.com", subresource_names = ["sql"], private_endpoint_name = "pe-cosmosdb" }
    openai        = { zone_name = "privatelink.cognitiveservices.azure.com", subresource_names = ["account"], private_endpoint_name = "pe-openai" }
  }

  enabled_pe_services = { for k, v in local.private_services : k => v if contains(keys(local.service_ids), k) }

  service_ids = {
    blob          = azurerm_storage_account.main.id
    acr           = azurerm_container_registry.main.id
    formrecog     = azurerm_cognitive_account.main["Document_Intelligence"].id
    search        = azurerm_search_service.main.id
    search-backup = azurerm_search_service.backup.id
    cosmosdb      = azurerm_cosmosdb_account.main.id
    openai        = azurerm_cognitive_account.main["Open_AI"].id
  }

  unique_zone_names = distinct([for k, v in local.private_services : v.zone_name])
  unique_dns_zones  = { for zone in local.unique_zone_names : zone => { zone_name = zone, link_name = "link-${replace(zone, ".", "-")}" } }
}