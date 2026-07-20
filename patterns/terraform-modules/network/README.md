# Module Network

This experiment tests the creation of a secured VNet with specialized subnets for PaaS integration. 

## Usage

I use this snippet to provision the VNet along with dedicated subnets for Azure Functions, App Services (with regional VNet integration enabled), and Private Endpoints:

```hcl
resource "azurerm_resource_group" "rg-workload-dev-001" {
  name     = rg-workload-dev-001
  location = northeurope
}

module "network" {
  source = "../modules/network"

  location                   = northeurope
  resource_group_name        = rg-workload-dev-001
  vnet_name                  = vnet-dev-ne-001
  address_space              = ["10.0.0.0/16"]
  function_subnet_prefixes   = ["10.0.1.0/24"]
  appservice_subnet_prefixes = ["10.0.2.0/24"]
  private_subnet_prefixes    = ["10.0.3.0/24"]
  
  depends_on                 = [azurerm_resource_group.rg-workload-dev-001]
}