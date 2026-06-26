variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "vnet_id" {
  type        = string
  description = "The target VNet ID to link with DNS zones"
}

variable "private_subnet_id" {
  type        = string
  description = "The subnet ID for the private endpoints"
}

variable "services_to_isolate" {
  type = map(object({
    resource_id       = string
    subresource_names = list(string)
    dns_zone_id       = string
    dns_zone_name     = string
  }))
  description = "Map of all services that need a private endpoint"
}