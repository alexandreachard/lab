# Terraform state refactoring

Renaming a resource and dropping another one from Terraform without destroying anything in Azure, with `moved {}` (Terraform 1.1) and `removed {}` (Terraform 1.7) instead of `terraform state mv` / `state rm`. Prep for the Terraform Associate (004).

## Why

Renaming `azurerm_linux_web_app.api` to `rag_api` in the code makes Terraform plan a destroy and a create: a new App Service, an outage. And deleting a block plans a destroy even when I only want another pipeline to manage the resource.

## What I learned

- `moved { from, to }` updates the address in the state: the plan shows "has moved to", 0 to add, 0 to destroy. The refresh still reads the resource.
- Keep `moved` blocks in shared modules: removing one is a breaking change, a user still on the old address gets a delete instead of a move.
- `removed { lifecycle { destroy = false } }` takes the resource out of the state and leaves it in Azure. It replaces the resource block in the code.
- `-replace` (Terraform 0.15.2+) recreates a resource in one apply and marks nothing in the state. `terraform taint` is deprecated.

## Run it

```sh
terraform init -backend=false
terraform validate
terraform plan    # against a state that still has azurerm_linux_web_app.api
```
