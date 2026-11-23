# Renovate as a Kubernetes CronJob

Self-hosted Renovate running every hour in my K3s cluster. It scans [k3s-gitops-homelab](https://github.com/alexandreachard/k3s-gitops-homelab) and opens a pull request when an image or a tool has a new version. Flux deploys it, the GitHub token is encrypted with SOPS.

## Why

I pin every image version in my manifests (no `latest`). Without a bot, nobody bumps them. Renovate opens the PR, I read the changelog and merge, and Flux rolls it out.

## Files in my cluster

In [infrastructure/controllers/base/renovate](https://github.com/alexandreachard/k3s-gitops-homelab/tree/main/infrastructure/controllers/base/renovate), applied by Flux:

- [cronjob.yaml](https://github.com/alexandreachard/k3s-gitops-homelab/blob/main/infrastructure/controllers/base/renovate/cronjob.yaml): `@hourly`, `concurrencyPolicy: Forbid`, `restartPolicy: Never`, the repo to scan as argument
- [configmap.yaml](https://github.com/alexandreachard/k3s-gitops-homelab/blob/main/infrastructure/controllers/base/renovate/configmap.yaml): platform `github`, autodiscover off, git author
- [renovate-container-env.yaml](https://github.com/alexandreachard/k3s-gitops-homelab/blob/main/infrastructure/controllers/base/renovate/renovate-container-env.yaml): `RENOVATE_TOKEN`, encrypted with SOPS
- [renovate.json](https://github.com/alexandreachard/k3s-gitops-homelab/blob/main/renovate.json) at the root of the scanned repo

## What I learned

- The `kubernetes` manager has no default file pattern: without one in `renovate.json`, it finds nothing.
- `fileMatch` is now `managerFilePatterns` (regex between `/.../`). Old configs are migrated automatically, and the same goes for `matchPackagePrefixes`, which becomes `matchPackageNames` with a glob.
- `concurrencyPolicy: Forbid`: if a run takes more than an hour, the next one is skipped instead of running two bots on the same branches.
- `restartPolicy: Never`: a bad token fails the Job once, no restart loop.
- GitHub token: a classic PAT needs `repo` (plus `workflow` to update GitHub Actions files). A fine-grained one needs Contents, Pull requests, Issues, Commit statuses and Workflows in read and write.

## Run it now

```sh
kubectl -n renovate create job --from=cronjob/renovate renovate-manual
kubectl -n renovate logs -f job/renovate-manual
kubectl -n renovate delete job renovate-manual
```
