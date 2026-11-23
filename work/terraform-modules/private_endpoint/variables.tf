variable "private_endpoint_name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "private_connection_resource_id" { type = string }
variable "subresource_names" { type = list(string) }
variable "subnet_id" { type = string }
variable "vnet_id" { type = string }
variable "private_dns_zone_id" { type = string }