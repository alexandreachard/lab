# Module : private_endpoint - modules/private_endpoint/main.tf

resource "azurerm_private_endpoint" "main" {
  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.private_endpoint_name}-connection"
    private_connection_resource_id = var.private_connection_resource_id
    subresource_names              = var.subresource_names
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name = "${var.private_endpoint_name}-dns-group"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}

output "private_endpoint_id" {
  value       = azurerm_private_endpoint.main.id
}

output "private_ip_address" {
  value       = azurerm_private_endpoint.main.private_service_connection[0].private_ip_address
}
