module "network" {
  source = "../modules/network"

  location                   = var.location
  resource_group_name        = local.resource_names.resource_group
  vnet_name                  = local.resource_names.vnet_name
  address_space              = var.address_space
  function_subnet_prefixes   = var.function_subnet_prefixes
  appservice_subnet_prefixes = var.appservice_subnet_prefixes
  private_subnet_prefixes    = var.private_subnet_prefixes
  depends_on                 = [azurerm_resource_group.main]
}

module "dns_zones" {
  # for_each = local.enabled_pe_services
  for_each = local.unique_dns_zones

  source              = "../modules/private_dns_zone"
  zone_name           = each.value.zone_name
  link_name           = each.value.link_name
  resource_group_name = local.resource_names.resource_group
  vnet_id             = module.network.vnet_id
}

module "private_endpoint" {
  for_each = local.enabled_pe_services

  source                         = "../modules/private_endpoint"
  location                       = var.location
  resource_group_name            = local.resource_names.resource_group
  private_connection_resource_id = lookup(local.service_ids, each.key)
  subresource_names              = each.value.subresource_names
  private_endpoint_name          = each.value.private_endpoint_name
  subnet_id                      = module.network.private_subnet_id
  vnet_id                        = module.network.vnet_id
  private_dns_zone_id = module.dns_zones[each.value.zone_name].zone_id

}

