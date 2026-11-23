# Terraform modules

Small Azure modules I reuse. [azure-private-endpoints](../azure-private-endpoints) and [azure-rag-network-isolation](../azure-rag-network-isolation) call them.

- `network/`: VNet with 3 subnets: Functions and App Service (delegated to `Microsoft.Web/serverFarms` for VNet integration), and Private Endpoints.
- `private_dns_zone/`: Private DNS zone linked to a VNet.
- `private_endpoint/`: Private Endpoint with its DNS zone group, so the A record is created in the private zone.
- `aca/`: Container Apps environment in an existing subnet, and an app that pulls its image from a shared ACR.

## Why

We deploy the same building blocks for several subsidiaries and projects. Modules with the same naming made new environments faster to build and kept them consistent.

## What I learned

- Container Apps pulling from ACR: with a system-assigned identity, the app has to exist before it gets AcrPull, so the first private image pull can't work. With a user-assigned identity, AcrPull is granted first. Microsoft recommends user-assigned when possible.
- `infrastructure_resource_group_name` is a resource group created by the platform: don't point it to an existing one. It only works with a workload profile.
- The Container Apps subnet (workload profiles) is dedicated: `/27` minimum, delegated to `Microsoft.App/environments`.
- `lifecycle { ignore_changes = [image] }`: Terraform creates the app, the CI pipeline deploys new images, and the next plan doesn't roll them back.
- Private Endpoints don't need network policies disabled on the subnet. Enabling them is only needed for NSG or route tables on the endpoints.

## Use

```hcl
module "private_endpoint" {
  source = "../terraform-modules/private_endpoint"

  private_endpoint_name          = "pe-storage"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  subnet_id                      = module.network.private_subnet_id
  private_connection_resource_id = azurerm_storage_account.main.id
  subresource_names              = ["blob"]
  private_dns_zone_id            = module.dns_blob.zone_id
}
```
