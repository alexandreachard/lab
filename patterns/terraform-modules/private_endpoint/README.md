# Module: Private Endpoint

This module abstracts the creation of an Azure Private Endpoint, automatically handling the private service connection and linking it to the appropriate Private DNS Zone group for automated name resolution.

## Usage

```hcl
module "storage_private_endpoint" {
  source = "../modules/private_endpoint"

  private_endpoint_name          = "pe-stplatformprod"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = module.network.private_subnet_id
  private_connection_resource_id = azurerm_storage_account.main.id
  subresource_names              = ["blob"]
  private_dns_zone_id            = azurerm_private_dns_zone.blob.id
}