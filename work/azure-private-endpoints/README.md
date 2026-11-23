# Azure Private Endpoints

One Private Endpoint per service from a single map (storage, Cosmos DB, Search, OpenAI...), with the VNet links to the private DNS zones. Uses the [private_endpoint module](../terraform-modules/private_endpoint).

## Why

Every PaaS service of a project needs the same thing: a Private Endpoint, its DNS zone group and a VNet link. Writing it once per service was copy-paste, so the services are a map and Terraform loops over it.

## What I learned

- A VNet can only be linked once to a private DNS zone. Two services in the same zone (two storage accounts in `privatelink.blob.core.windows.net`) need one link, not two: the links loop over the distinct zones.
- The DNS zone group on the Private Endpoint creates the A record in the private zone, no manual record.
- The zone depends on the endpoint the client uses: an OpenAI account answers on `*.openai.azure.com`, so it needs `privatelink.openai.azure.com`, not only `privatelink.cognitiveservices.azure.com`.

## Run it

```hcl
services_to_isolate = {
  blob = {
    resource_id       = "<storage account id>"
    subresource_names = ["blob"]
    dns_zone_id       = "<privatelink.blob.core.windows.net zone id>"
    dns_zone_name     = "privatelink.blob.core.windows.net"
  }
}
```

```sh
terraform init
terraform plan -var-file=terraform.tfvars
```
