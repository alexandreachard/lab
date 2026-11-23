# One link per DNS zone, not per service: a VNet can only be linked once to a zone
resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  for_each              = toset([for s in var.services_to_isolate : s.dns_zone_name])
  name                  = "link-${replace(each.key, ".", "-")}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.key
  virtual_network_id    = var.vnet_id
}

# One Private Endpoint per service
module "private_endpoints" {
  source                         = "../terraform-modules/private_endpoint"
  for_each                       = var.services_to_isolate
  private_endpoint_name          = "pe-${each.key}"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = var.private_subnet_id
  private_connection_resource_id = each.value.resource_id
  subresource_names              = each.value.subresource_names
  private_dns_zone_id            = each.value.dns_zone_id
}