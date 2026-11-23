# Azure Subscription Manager

PowerShell script that renames a batch of subscriptions (`sub-sandbox-01`, `02`...) and moves them into a management group, with Azure CLI.

## Why

About 50 new subscriptions were added at the root level, with generic names outside our naming convention.
They had to be renamed and moved into a landing zone management group.
It's a one-time cleanup of existing subscriptions: a script was simpler than importing 50 subscriptions into Terraform.

## What I learned

- A new subscription lands in the root management group by default, unless a default management group is set in the hierarchy settings.
- Moving a subscription: check permissions on the subscription, the current management group and the target one (unless the current one is the root), not only on the target.
- Dry run first, then filter in two steps: a prefix in the `az` query, then a strict regex to exclude other naming variants.
- `az account subscription rename` is in the `account` CLI extension, still experimental.
- The portal can take up to 30 minutes to show the new hierarchy (Resource Manager caches it).

## Run it

Edit the variables at the top of `move-and-rename.ps1` (`$TARGET_MG`, `$PREFIX`, `$REGEX`), keep `$DRY_RUN = $true`, then:

```sh
az login
./move-and-rename.ps1    # prints the plan only
```

Set `$DRY_RUN = $false` and run it again to apply.

Check:

```sh
az account management-group show --name "mg-workloads-sandbox" --expand --recurse -o table
```

Rollback, one subscription at a time:

```sh
az account subscription rename --subscription-id "<SUBSCRIPTION_ID>" --name "<OLD_NAME>"
az account management-group subscription add --name "<SOURCE_MG>" --subscription "<SUBSCRIPTION_ID>"
```
