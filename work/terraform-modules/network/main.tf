# Module : network - modules/network/main.tf

# creates the vnet
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
}

# creates 3 subnets 
resource "azurerm_subnet" "function_subnet" {
  name                 = "subnet-function"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.function_subnet_prefixes
  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
    }
  }
  service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "appservice_subnet" {
  name                 = "subnet-appservice"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.appservice_subnet_prefixes
  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
    }
  }
  service_endpoints = ["Microsoft.Storage","Microsoft.AzureCosmosDB"]
}


resource "azurerm_subnet" "private_endpoints_subnet" {
  name                 = "subnet-private-endpoints"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.private_subnet_prefixes

  private_endpoint_network_policies = "Disabled"
  service_endpoints = ["Microsoft.Storage"]
}

output "vnet_id" {
  value = azurerm_virtual_network.main.id
}

output "function_subnet_id" {
  value = azurerm_subnet.function_subnet.id
}

output "private_subnet_id" {
  value = azurerm_subnet.private_endpoints_subnet.id
}

output "appservice_subnet_id" {
  value = azurerm_subnet.appservice_subnet.id
}