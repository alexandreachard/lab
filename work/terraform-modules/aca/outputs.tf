output "container_app_url" {
  value       = "https://${azurerm_container_app.web_app.ingress[0].fqdn}"
}