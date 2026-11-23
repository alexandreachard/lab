terraform {
  required_providers {
    netbox = {
      source  = "e-breuninger/netbox"
      version = "~> 6.0" # 6.0 supports NetBox 4.6.8 - 4.6.10
    }
  }
}

# Or leave the variables empty and set NETBOX_SERVER_URL / NETBOX_API_TOKEN
provider "netbox" {
  server_url = var.netbox_url
  api_token  = var.netbox_api_token
}