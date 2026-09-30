# Pattern: Modern Terraform State Refactoring (Terraform 1.7+)

Zero-downtime refactoring and declarative state management patterns applied to Azure infrastructure, using native HCL blocks introduced in Terraform 1.1+ and 1.7+.

---

## The Problem: The Naive Refactoring Pitfall

In traditional Terraform workflows, renaming a resource or moving it to a module causes a destructive plan:

```
Naive HCL Renaming:
  [azurerm_linux_web_app.api] deleted     ──► Azure API: Destroy App Service (Outage, lost IPs/TLS)
  [azurerm_linux_web_app.rag_api] created ──► Azure API: Create fresh App Service
```

Similarly, removing a resource block from HCL automatically schedules a cloud destruction (`destroy`), even when the intention was only to delegate management to another team or pipeline.

---

## The Solution: Declarative State Primitives

```
┌───────────────────────────────────────┬────────────────────────────────────────────────────────┐
│ Pattern                               │ Under the Hood Behavior                                │
├───────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ moved {                               │ Updates state address mapping in-place.                │
│   from = azurerm_linux_web_app.api    │ Zero API calls to Azure.                               │
│   to   = azurerm_linux_web_app.rag_api│ Plan: 0 to add, 0 to change, 0 to destroy.             │
│ }                                     │                                                        │
├───────────────────────────────────────┼────────────────────────────────────────────────────────┤
│ removed {                             │ Ejects address from .tfstate file.                     │
│   from = azurerm_storage_account.data │ destroy = false: Leaves Azure cloud resource intact.  │
│   lifecycle { destroy = false }       │ destroy = true:  Deletes Azure resource + purges state.│
│ }                                     │ (Declarative replacement for `terraform state rm`).    │
└───────────────────────────────────────┴────────────────────────────────────────────────────────┘
```

---

## Directory Structure

```
patterns/terraform-state-refactoring/
├── main.tf
├── variables.tf
└── README.md
```

---

## Exam & Production Traps: `replace` vs `removed`

A critical distinction frequently tested in the **HashiCorp Terraform Associate 004** exam:

| Operation | Command / Block | State Action | Cloud Infrastructure Action |
| :--- | :--- | :--- | :--- |
| **Recreate Resource** | `terraform apply -replace="addr"` *(formerly `taint`)* | **Retained in state** (marked degraded) | Destroys and recreates resource on next apply. |
| **Unmanage Resource** | `removed { lifecycle { destroy = false } }` *(formerly `state rm`)* | **Removed from state** | **Untouched in cloud** (Resource survives). |
| **Purge Resource** | `removed { lifecycle { destroy = true } }` | **Removed from state** | **Destroyed in cloud**. |

---

## Validation & Workflow

### 1. Initialize and Validate

```bash
cd patterns/terraform-state-refactoring

terraform init -backend=false
terraform validate
```

### 2. Preview the Refactoring Plan

When running `terraform plan` on a state where `azurerm_linux_web_app.api` already exists:

```bash
terraform plan
```

Output highlights:
```text
Terraform will perform the following actions:

  # azurerm_linux_web_app.api has moved to azurerm_linux_web_app.rag_api
    resource "azurerm_linux_web_app" "rag_api" {
        id = "/subscriptions/.../providers/Microsoft.Web/sites/app-rag-api-staging"
        # ... attributes unchanged
    }

  # azurerm_storage_account.rag_data will no longer be managed by Terraform
    # (destroy = false in removed block)

Plan: 0 to add, 0 to change, 0 to destroy.
```

### 3. Commit to Git

Once applied across all environments (`dev`, `staging`, `prod`), `moved` and `removed` blocks can be safely committed to the repository, providing full auditability through Pull Requests.
