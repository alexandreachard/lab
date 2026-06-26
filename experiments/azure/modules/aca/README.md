# Module: Azure Container Apps Environment & App

This module provisions an Azure Container App Environment (ACE) inside an existing infrastructure subnet, deploys a managed Container App instance, and configures the required Managed Identity permissions to securely pull images from a shared Azure Container Registry (ACR).

## Usage

I use this snippet to instantiate a dedicated application environment and secure its container deployment workflow:

```hcl
module "container_app_dev" {
  source = "../modules/azure_container_app"

  env_name                  = "dev"
  location                  = "northeurope"
  subnet_id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-workload-dev-001/providers/Microsoft.Network/virtualNetworks/vnet-dev-ne-001/subnets/snet-app"
  acr_login_server          = "crplatformshared001.azurecr.io"
  shared_acr_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-shared-core-001/providers/Microsoft.ContainerRegistry/registries/crplatformshared001"
  min_replicas              = 1
  fabric_endpoint_address   = "your-fabric-endpoint.datawarehouse.pbidedicated.windows.net"
  fabric_warehouse_name     = "dw_workload_dev"
}