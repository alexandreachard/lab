# Module: Private AI RAG Architecture

In this experiment, I provision a fully network-isolated Retrieval-Augmented Generation (RAG) backend infrastructure. It implements strict perimeter security, ensuring that my compute services (App Service, Function App) communicate with data layers (CosmosDB, Blob Storage, Azure AI Search) exclusively over private endpoints, completely disabling public internet ingress.

## Functional Domain Layering

I refactored the codebase into domain-centric blocks rather than standalone resource components to mirror enterprise platform modularity:

* **`network.tf`**: Establishes my core VNet, delegated integrations subnets, Azure Private DNS Zones, and Private Endpoints.
* **`compute.tf`**: Hosts my web frontend application runtime, API orchestration services, ingestion Azure Functions, Application Insights workspaces, and my private Azure Container Registry (ACR).
* **`data.tf`**: Provisions my private persistent backends and data plane systems (CosmosDB, Blob Storage buckets, Azure AI Search clusters, and Document Intelligence engines).

## Centralized Naming & Configuration Engine (`locals.tf`)

I use a centralized deterministic naming standard to dynamically generate compliant resource identifiers based on environment type inputs:

```hcl
locals {
  environment_name = lower(var.tags["Environment"])
  environment_code = lower(var.tags["Environment"]) == "production" ? "prd" : "dev"
  
  prefix = "rag-${local.environment_code}"

  resource_names = {
    resource_group        = "${local.prefix}-rg-backend"
    cosmosdb_account      = "${local.prefix}-cosmos-db"
    search                = "${local.prefix}-srch-core"
    storage               = "rag${local.environment_code}stocore"
    functionapp           = "${local.prefix}-functionapp"
    vnet_name             = "${local.prefix}-vnet"
  }
}
```

## Usage
I use a terraform.tfvars file configured like this one to feed my parameters:

```hcl
location = "swedencentral"

tenant_id = "00000000-0000-0000-0000-000000000000"
client_id = "00000000-0000-0000-0000-000000000000"
tags = {
  Environment = "development"
  Project     = "rag-privacy-validation"
}
address_space              = ["10.231.0.0/16"]
function_subnet_prefixes   = ["10.231.2.0/24"] 
appservice_subnet_prefixes = ["10.231.3.0/24"] 
private_subnet_prefixes    = ["10.231.4.0/24"] 

ip_range_filter-cosmosdb = [
# add allowed ips here
]

ip_range_filter_blob = [
# add allowed ips here
]

# CosmosDB SQL Containers
cosmosdb_sql_containers = {
  conversations = {
    name               = "conversations"
    partition_key_path = "/userId"
  }
  messages = {
    name               = "messages"
    partition_key_path = "/conversationId"
  }
  users = {
    name               = "users"
    partition_key_path = "/userId"
  }
}

# App Service
apps = {
  "front" = {
    suffix            = "ui"
    docker_image_name = "nginx:latest"
    app_settings      = {}
  }
  "api" = {
    suffix            = "web-api"
    docker_image_name = "python-rag-api:latest"
    app_settings      = {
      LOG_LEVEL = "DEBUG"
    }
  }
}

cognitive_accounts = {
  Document_Intelligence = {
    kind       = "FormRecognizer"
    sku_name   = "S0"
    ip_rules   = []
    acl_action = "Deny"
    cdn_suffix = "docintel"
  }
  Open_AI = {
    kind       = "OpenAI"
    sku_name   = "S0"
    ip_rules   = []
    acl_action = "Deny"
    cdn_suffix = "openai"
  }
}
```

And I run this execution sequence to deploy the infrastructure stack:
```bash
terraform init
terraform plan -var-file="terraform.tfvars" -out=rag.tfplan
terraform apply rag.tfplan
```