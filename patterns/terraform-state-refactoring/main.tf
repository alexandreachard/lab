# patterns/terraform-state-refactoring/main.tf
# Demonstrates zero-downtime refactoring and declarative state management for Azure workloads.

terraform {
  required_version = ">= 1.7.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

provider "azurerm" {
  features {}
}

# ─────────────────────────────────────────────────────────────────────────────
# 1. Target Infrastructure (After Refactoring)
# ─────────────────────────────────────────────────────────────────────────────

resource "azurerm_resource_group" "rg" {
  name     = "rg-rag-${var.environment}"
  location = var.location
}

resource "azurerm_service_plan" "asp" {
  name                = "asp-rag-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = var.asp_sku
}

# Modernized resource name: 'rag_api' instead of legacy 'api'
resource "azurerm_linux_web_app" "rag_api" {
  name                = "app-rag-api-${var.environment}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    always_on = true
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# 2. Declarative Address Translation: moved {} (Terraform 1.1+)
# ─────────────────────────────────────────────────────────────────────────────
# Prevents destroying and recreating the App Service during renaming.
# Translates state address in-place without triggering Azure API deletion.
# Result: 0 to add, 0 to change, 0 to destroy.

moved {
  from = azurerm_linux_web_app.api
  to   = azurerm_linux_web_app.rag_api
}

# ─────────────────────────────────────────────────────────────────────────────
# 3. Declarative State Ejection: removed {} (Terraform 1.7+)
# ─────────────────────────────────────────────────────────────────────────────
# Scenario A: Eject resource from Terraform state WITHOUT destroying Azure resource.
# Use case: Resource is migrated to another pipeline or managed by central governance team.
# Replaces imperative command: `terraform state rm azurerm_storage_account.rag_data`

removed {
  from = azurerm_storage_account.rag_data

  lifecycle {
    destroy = false
  }
}

# Scenario B: Declaratively destroy an obsolete cloud resource through Git review.
# Keeps an audit trail in PR before completely purging the block.

removed {
  from = azurerm_cognitive_account.legacy_search

  lifecycle {
    destroy = true
  }
}
