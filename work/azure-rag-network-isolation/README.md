# Azure RAG network isolation

Infrastructure of a RAG application on Azure where everything talks over Private Endpoints: App Service (front and API), a Function App for indexing, Cosmos DB, Blob Storage, AI Search, Azure OpenAI, Document Intelligence and ACR.

- `network.tf`: VNet and subnets ([network module](../terraform-modules/network)), private DNS zones, Private Endpoints.
- `compute.tf`: App Service, Function App, ACR, Application Insights.
- `data.tf`: Cosmos DB, storage, AI Search, Cognitive Services accounts.
- `locals.tf`: naming from the `Environment` tag (`rag-dev-...`, `rag-prd-...`) and the list of services that get a Private Endpoint.

## Why

I deploy generative AI platforms (Azure OpenAI, AI Search, Container Apps, Private Endpoints) for several production and development environments. It started as a proof of concept; this version is the refactoring with modules, variables and one naming standard, so a new environment is a new tfvars file.

## What I learned

- Two services can share a private DNS zone (Document Intelligence and other Cognitive Services accounts), so the zones are created from the distinct zone names, not one per service.
- Azure OpenAI answers on `*.openai.azure.com`: its Private Endpoint needs `privatelink.openai.azure.com`.
- App Service and Function App pull from ACR with their managed identity (`container_registry_use_managed_identity` + AcrPull), no admin user.
- What I'd change: the API and the Function App still get keys and connection strings in their app settings, so they are also in plain text in the Terraform state. Next step is managed identity with data plane roles (Cognitive Services OpenAI User, Search Index Data Reader/Contributor, the Cosmos DB built-in data roles, Storage Blob Data Contributor), or Key Vault references at least. It needs changes in the application code too.

## Run it

```sh
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan -var-file=terraform.tfvars -out=rag.tfplan
terraform apply rag.tfplan
```
