output "isolated_service_ips" {
  value       = { for k, v in module.private_endpoints : k => v.private_ip_address }
  description = "Map of service keys and their private IP addresses"
}