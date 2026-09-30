# Azure Subscription Batch Manager

PowerShell script to batch rename and move Azure subscriptions to a target **Management Group** using Azure CLI (`az`).

---

## Why This Script vs Azure Policy or Terraform?

A common architectural question is whether subscription renaming and Management Group placement can be automated natively via **Azure Policy** or **Terraform**:

| Approach | Native Capabilities & Limitations | Why This Script Wins for Batch Onboarding |
| :--- | :--- | :--- |
| **Azure Policy** | ❌ **Unsupported by design.** Azure Policy governs ARM resources *inside* subscriptions (tags, SKUs, encryption). It has no `modify` or `append` effect capable of mutating the subscription's root `displayName`. Furthermore, Policy cannot evaluate subscription naming patterns at the Tenant Root Group to dynamically relocate subscriptions into child Management Groups. | Direct API call via Azure CLI bypasses Policy engine scope limitations. |
| **Terraform (IaC)** | ⚠️ **Heavyweight for brownfield intake.** While `azurerm_management_group_subscription_association` handles declarative placement, managing 50 unorganized subscriptions requires 50 pre-existing `import {}` blocks and extensive state reconciliation for a one-time reorganization. | Ideal pre-IaC sanitization tool: normalizes names and hierarchy *before* onboarding to Terraform Landing Zones. |
| **Event Grid + Logic App** | ⚠️ **High operational overhead.** Requires provisioning and maintaining event-driven infrastructure just for batch subscription intake. | Zero infrastructure footprint: runs directly from any engineer terminal or CI runner in seconds. |
| **IAM Privilege Boundary** | 💡 Platform engineers rarely have `Owner` or `Contributor` rights on the **Tenant Root Group** in enterprise environments. | **Least privilege trick:** With only `Reader` on source subscriptions and `Contributor` on the destination Management Group, the script pulls subscriptions into the target MG without requiring root-level elevation. |

---

## Use Case

When provisioning subscriptions in an Azure Landing Zone, subscriptions initially land under the **Tenant Root Group** with legacy or generic names. This script:
1. Filters subscriptions by prefix and regex pattern.
2. Previews the rename and move operations (`$DRY_RUN = $true`).
3. Renames subscriptions sequentially (`sub-sandbox-01`, `02`, etc.).
4. Moves them into the target Management Group with a 2-second rate-limit pause.

---

## Prerequisites & IAM Permissions

| Requirement | Details |
| :--- | :--- |
| **Azure CLI** | `az` installed and authenticated (`az login`) |
| **PowerShell** | PowerShell 7+ (`pwsh`) or Windows PowerShell 5.1 |
| **Subscription IAM** | `Reader` role on source subscriptions |
| **Management Group IAM** | `Management Group Contributor` (or `Owner`) on the target Management Group |
| **Tenant Root Group** | **No permissions required** on root; `az account list --all` retrieves subscriptions directly. |

---

## Directory Structure

```
tools/azure-subscription-manager/
├── move-and-rename.ps1
└── README.md
```

---

## Configuration

Edit the top variables in `move-and-rename.ps1`:

```powershell
$TARGET_MG = "mg-workloads-sandbox"  # Destination Management Group name
$DRY_RUN   = $true                  # Keep $true for simulation, change to $false to apply
$counter   = 1                      # Starting sequence number
$PREFIX    = "legacy-sub"           # Fast query prefix
$REGEX     = '^legacy-sub-\d+$'     # Strict regex pattern
```

---

## Usage

### 1. Pre-flight Checks

Ensure Azure CLI is connected and can read the destination Management Group:

```bash
# Check authenticated account
az account show -o table

# Verify target Management Group exists
az account management-group show --name "mg-workloads-sandbox" -o table

# Check subscriptions matching prefix
az account list --all \
  --query "[?starts_with(name, 'legacy-sub') && state=='Enabled'].{name:name, id:id}" \
  -o table
```

### 2. Dry Run (Simulation)

Run the script with `$DRY_RUN = $true`:

```powershell
./move-and-rename.ps1
```

Output:
```text
=== Fetching subscriptions matching prefix 'legacy-sub' ===
Found 3 matching subscription(s)

=== PLAN ===
  legacy-sub-01 -> sub-sandbox-01  (move to mg-workloads-sandbox)
  legacy-sub-02 -> sub-sandbox-02  (move to mg-workloads-sandbox)
  legacy-sub-03 -> sub-sandbox-03  (move to mg-workloads-sandbox)

DRY RUN — set $DRY_RUN = $false in script to execute
```

### 3. Execution

Set `$DRY_RUN = $false` in `move-and-rename.ps1` and run:

```powershell
./move-and-rename.ps1
```

---

## Post-Execution Verification

```bash
# Verify subscriptions under target Management Group
az account management-group show --name "mg-workloads-sandbox" --expand --recurse -o table

# Verify updated names
az account list --all \
  --query "[?starts_with(name, 'sub-sandbox')].{name:name, id:id}" \
  -o table
```

---

## Rollback

Each action can be rolled back individually:

```bash
# 1. Restore previous subscription name
az account subscription rename --subscription-id "<SUBSCRIPTION_ID>" --name "<OLD_NAME>"

# 2. Move back to previous Management Group
az account management-group subscription add --name "<SOURCE_MG_ID>" --subscription "<SUBSCRIPTION_ID>"
```
