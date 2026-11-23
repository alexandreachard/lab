# Azure Governance

Management groups let you apply policies and IAM roles, inherited by every subscription they contain.
Here: a platform / workloads (non-prod, prod) hierarchy, 2 subscriptions attached, team access with Entra groups, and an Allowed locations policy on prod.

## Why

At work I manage more than 50 subscriptions. Managing them one by one doesn't scale:
- permissions granted subscription by subscription;
- several teams that need access to a set of subscriptions;
- resources deployed in any region.

With management groups, a role or a policy assigned once applies to every subscription below it.

## What I learned

- Inheritance: a policy or a role on a management group applies to every subscription below it.
- Layout: platform on one side, workloads on the other, then non-prod / prod.
- Access per team, not per person: one Entra group per team, assigned on the management group. Team A is Contributor in non-prod and Reader in prod, only Ops is Contributor in prod.
- Moving a subscription: you need permissions on the subscription, on the target management group and on the current one (unless it's the root management group).
- Allowed locations doesn't apply to resource groups: they need a separate policy.
- The `name` of a policy assignment on a management group is limited to 24 characters.

## Run it

Prerequisite: `az login` with permissions on the tenant root (to create management groups).

```sh
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan -var-file=terraform.tfvars
```

Adjust the regions and the policy to your needs.
