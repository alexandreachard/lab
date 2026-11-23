terraform {
  required_providers {
    netbox = {
      source  = "e-breuninger/netbox"
      version = "~> 5.0.0"
    }
  }
}
provider "netbox" {
  server_url = "https://mycustomurl.local"
  api_token  = "my-api-secret-token"
}