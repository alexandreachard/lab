# Module: Private DNS Zone

This module provisions an Azure Private DNS Zone and automatically links it to a target Virtual Network, enabling internal name resolution across your infrastructure.

## Usage

I use this snippet to create a private DNS zone for Azure Container Apps (or other PaaS resources) and link it directly to the workload VNet:

```hcl
resource "azurerm_resource_group" "rg-workload-dev-001" {
  name     = "rg-workload-dev-001"
  location = "northeurope"
}

module "private_dns" {
  source = "../modules/private_dns_zone"

  zone_name           = "privatelink.azurecontainerapps.io"
  resource_group_name = "rg-workload-dev-001"
  link_name           = "vnet-dev-ne-001-link"
  vnet_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-workload-dev-001/providers/Microsoft.Network/virtualNetworks/vnet-dev-ne-001"

  depends_on = [azurerm_resource_group.rg-workload-dev-001]
}