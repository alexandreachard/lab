# Module: NetBox IPAM Provisioning

In this experiment, I test programmatic IP Address Management (IPAM) provisioning workflows. I use a dedicated third-party NetBox Terraform provider to manage network aggregates, prefixes, and IP allocations directly from code.

## Usage

I use this snippet to instantiate global network boundaries and automate the registration of internal enterprise subnets within my NetBox source of truth:

```hcl
terraform {
  required_providers {
    netbox = {
      source  = "e-breuninger/netbox"
      version = "~> 3.0"
    }
  }
}

provider "netbox" {
  server_url = var.netbox_url
  api_token  = var.netbox_api_token
}

resource "netbox_aggregate" "global_corp" {
  prefix      = "10.0.0.0/8"
  description = "Global Corporate Network Aggregate"
}

resource "netbox_prefix" "dev_spoke" {
  prefix       = "10.231.56.0/21"
  status       = "active"
  vrf_id       = var.netbox_vrf_id
  tenant_id    = var.netbox_tenant_id
  description  = "Managed by Terraform - GCP Dev Spoke Subnet"
}