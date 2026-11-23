# Pattern: Azure Enterprise Governance (Management Groups)

This pattern demonstrates how I build a scalable Azure Landing Zone hierarchy to systematically organize and govern multiple cloud subscriptions.

## My Hierarchy Structure

* **`Org-Root`**: The top-level root group directly under my Tenant Root.
  * **`Platform`**: Houses my shared infrastructure subscriptions like Hub VNets, Shared Firewalls, and Core Log Analytics workspaces.
  * **`Workloads`**: Houses my business application subscriptions, which I split by lifecycle stages:
    * **`Non-Prod`**: Implements lighter cost controls and allows flexible developer access for rapid prototyping.
    * **`Production`**: Enforces strict network isolation, rigid Azure Policies (like mandatory Private Endpoints), and highly restricted RBAC access.

## Why This Matters

Building this structure allows me to apply strict security baselines and Azure Policies at a high level. Any new subscription I drop into the `Production` Management Group instantly inherits all corporate compliance controls without requiring manual configuration.