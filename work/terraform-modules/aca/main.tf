resource "azurerm_resource_group" "env" {
  name     = "rg-project-app-${var.env_name}"
  location = var.location
}

resource "azurerm_container_app_environment" "ace" {
  name                               = "ace-${var.env_name}"
  location                           = azurerm_resource_group.env.location
  resource_group_name                = azurerm_resource_group.env.name
  infrastructure_resource_group_name = "rg-project-app-${var.env_name}-infra" # created by the platform, must not be an existing RG
  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
  infrastructure_subnet_id       = var.subnet_id
  internal_load_balancer_enabled = false
  #true if using APIM
}

# User-assigned identity: AcrPull is granted before the app exists, so the first pull works
resource "azurerm_user_assigned_identity" "app" {
  name                = "id-webapp-${var.env_name}"
  location            = azurerm_resource_group.env.location
  resource_group_name = azurerm_resource_group.env.name
}

resource "azurerm_role_assignment" "acr_pull_auth" {
  scope                = var.shared_acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}

resource "azurerm_container_app" "web_app" {
  name                         = "webapp-${var.env_name}"
  container_app_environment_id = azurerm_container_app_environment.ace.id
  resource_group_name          = azurerm_resource_group.env.name
  revision_mode                = "Single"
  ingress {
    external_enabled = true
    target_port      = 80
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }
  registry {
    server   = var.acr_login_server
    identity = azurerm_user_assigned_identity.app.id
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = 3
    container {
      name   = "web-application-container"
      image  = "${var.acr_login_server}/webapp-${var.env_name}:initial"
      cpu    = "0.5"
      memory = "1.0Gi"

      dynamic "env" {
        for_each = var.app_env
        content {
          name  = env.key
          value = env.value
        }
      }
    }
  }

  depends_on = [azurerm_role_assignment.acr_pull_auth]

  lifecycle {
    ignore_changes = [template[0].container[0].image] # the CI pipeline deploys new images, not Terraform
  }
}
