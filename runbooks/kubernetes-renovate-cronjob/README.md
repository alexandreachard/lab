# Runbook: Renovate Bot as a Kubernetes CronJob

Deploy a self-hosted **Renovate Bot** instance inside Kubernetes using a native `CronJob`, automated via GitOps (FluxCD) and secured with Mozilla SOPS/Age.

---

## Architecture Overview

```
                      Scheduled Trigger (@hourly)
                                 │
                                 ▼
                     ┌───────────────────────┐
                     │   Kubernetes CronJob  │
                     │  (renovate namespace) │
                     └───────────┬───────────┘
                                 │ Spawns transient Pod
                                 ▼
                     ┌───────────────────────┐
                     │     Renovate Pod      │
                     │  Image: renovate:latest│
                     └─────┬───────────┬─────┘
                           │           │
           Reads ConfigMap │           │ Authenticates via Secret (SOPS)
                           ▼           ▼
             [ renovate-configmap ]  [ renovate-container-env ]
                           │
                           ▼ Scans repository
                 [ GitHub Repository ]
                           │
                           ▼ Opens PR on version bump
                 [ Pull Request (PR) ]
```

---

## Directory Structure

```
runbooks/kubernetes-renovate-cronjob/
├── manifests/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── secret-template.yaml
│   └── cronjob.yaml
└── README.md
```

---

## Prerequisites

1. **GitHub Personal Access Token (Fine-grained or Classic PAT):**
   - Scopes required: `repo` (Full control) and `workflow` (if Renovate updates GitHub Actions).
2. **Mozilla SOPS + Age** (if storing secrets in GitOps):
   - To encrypt the secret before committing to Git.

---

## Deployment Steps

### 1. Configure the Target Repository in ConfigMap

Edit `manifests/configmap.yaml` to adjust the bot identity if necessary:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: renovate-configmap
  namespace: renovate
data:
  RENOVATE_AUTODISCOVER: "false"
  RENOVATE_GIT_AUTHOR: "Renovate Bot <bot@renovateapp.com>"
  RENOVATE_PLATFORM: "github"
```

### 2. Configure the GitHub Secret

Create the secret containing the GitHub PAT:

```bash
# Direct imperative creation (local testing)
kubectl create secret generic renovate-container-env \
  --namespace renovate \
  --from-literal=RENOVATE_TOKEN="ghp_your_pat_token_here"

# OR with SOPS for GitOps workflows:
# 1. Fill manifests/secret-template.yaml with your plaintext token
# 2. Encrypt with Age:
sops --encrypt --in-place \
  --encrypted-regex '^(data|stringData)$' \
  manifests/secret-template.yaml
```

### 3. Update the Target Repository in CronJob

In `manifests/cronjob.yaml`, replace `<GITUSER/REPO>` with your actual repository path (e.g. `alexandreachard/dell-cluster`):

```yaml
spec:
  schedule: "@hourly"
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: renovate
              image: renovate/renovate:latest
              args:
                - <GITUSER/REPO>
              envFrom:
                - secretRef:
                    name: renovate-container-env
                - configMapRef:
                    name: renovate-configmap
          restartPolicy: Never
```

#### Critical Spec Fields Explained

| Field | Setting | Reason |
| :--- | :--- | :--- |
| `schedule` | `@hourly` | Runs once every hour. Avoids GitHub API rate limiting while keeping dependencies updated quickly. |
| `concurrencyPolicy` | `Forbid` | Prevents concurrent runs. If a scan takes longer than an hour, the next job is skipped to prevent git branch conflicts. |
| `restartPolicy` | `Never` | If the container fails (API error, invalid token), it won't restart in an infinite crash loop. |

### 4. Enable the Kubernetes Manager in the Target Repository

At the root of the scanned repository, add a `renovate.json` configuration file:

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "kubernetes": {
    "fileMatch": [
      "\\.yaml$"
    ]
  }
}
```

This tells Renovate to inspect all `.yaml` files for container images (`spec.containers[*].image`).

---

## Validation & Operations

### Manually trigger a run (without waiting for the schedule)

```bash
# Create a Job from the CronJob definition
kubectl create job --from=cronjob/renovate manual-test-01 -n renovate

# Stream execution logs
kubectl logs -n renovate job/manual-test-01 -f

# Clean up manual job once finished
kubectl delete job manual-test-01 -n renovate
```

### Review PRs opened by the Bot

```bash
# List PRs with GitHub CLI
gh pr list --repo <GITUSER/REPO>

# Inspect details and release changelog
gh pr view <PR_NUMBER> --repo <GITUSER/REPO>

# Merge PR
gh pr merge <PR_NUMBER> --merge --delete-branch --repo <GITUSER/REPO>
```

---

## Troubleshooting

| Issue | Cause | Fix |
| :--- | :--- | :--- |
| **HTTP 401 / 403 Unauthorized** | GitHub PAT is invalid, expired, or missing `repo` scope. | Regenerate a fine-grained token, update the secret, and verify authentication. |
| **CronJob does not trigger** | Previous Job pod is still running or stuck in `Error`. `concurrencyPolicy: Forbid` blocks new jobs. | Check `kubectl get pods -n renovate` and clean up zombie pods. |
| **No PRs created** | `fileMatch` in `renovate.json` does not match manifests, or repository already up to date. | Check logs (`DEBUG` level can be enabled with `LOG_LEVEL=debug` in ConfigMap). |
