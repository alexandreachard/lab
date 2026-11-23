variable "netbox_url" {
  type        = string
  description = "NetBox URL. Leave null to use NETBOX_SERVER_URL"
  default     = null
}

variable "netbox_api_token" {
  type        = string
  description = "NetBox API token (v1 or v2). Leave null to use NETBOX_API_TOKEN"
  default     = null
  sensitive   = true
}
