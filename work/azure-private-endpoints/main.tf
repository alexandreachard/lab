# We link the DNS zone to the VNet first
resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  for_each              = var.services_to_isolate
  name                  = "link-${each.key}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value.dns_zone_name
  virtual_network_id    = var.vnet_id
}

# Then we call the existing module to create the endpoints
module "private_endpoints" {
  source   = "../../experiments/azure/modules/private_endpoint"
  for_each = var.services_to_isolate
  vnet_id                        = var.vnet_id
  private_endpoint_name          = "pe-${each.key}"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.private_subnet_id
  private_connection_resource_id = each.value.resource_id
  subresource_names              = each.value.subresource_names
  private_dns_zone_id            = each.value.dns_zone_id
}