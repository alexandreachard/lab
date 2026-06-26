# Root Management Group for the Tenant or Organization
resource "azurerm_management_group" "root" {
  display_name = "${var.org-name}-Root"
  name         = "${var.org-name}-root"
}

# Core Platform Management Group (for Network, Shared Services, Logging)
resource "azurerm_management_group" "platform" {
  display_name               = "Platform"
  name                       = "${var.org-name}-platform"
  parent_management_group_id = azurerm_management_group.root.id
}

# Workloads Management Group (for Environments like Dev, QA, Prod)
resource "azurerm_management_group" "workloads" {
  display_name               = "Workloads"
  name                       = "${var.org-name}-workloads"
  parent_management_group_id = azurerm_management_group.root.id
}

# Sub-Management Groups for lifecycle staging inside Workloads
resource "azurerm_management_group" "non_prod" {
  display_name               = "Non-Prod"
  name                       = "${var.org-name}-workloads-nonprod"
  parent_management_group_id = azurerm_management_group.workloads.id
}

resource "azurerm_management_group" "prod" {
  display_name               = "Production"
  name                       = "${var.org-name}-workloads-prod"
  parent_management_group_id = azurerm_management_group.workloads.id
}

# Automatically associate subscriptions to their designated targets
resource "azurerm_management_group_subscription_association" "dev_sub" {
  management_group_id = azurerm_management_group.non_prod.id
  subscription_id     = "/subscriptions/${var.dev_subscription_id}"
}

resource "azurerm_management_group_subscription_association" "prod_sub" {
  management_group_id = azurerm_management_group.prod.id
  subscription_id     = "/subscriptions/${var.prod_subscription_id}"
}