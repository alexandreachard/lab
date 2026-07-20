# Dev Containers

Reusable dev container images for my homelab and cloud projects.  
Built for **VS Code / GitHub Codespaces** with **Podman** on Fedora.

## Architecture

Each devcontainer follows the same 3-layer pattern:

```
┌─────────────────────────────────────┐
│  3. mise.toml       tools per use-case
├─────────────────────────────────────┤
│  2. scripts/setup   postCreate hook
├─────────────────────────────────────┤
│  1. Dockerfile      base image + mise
└─────────────────────────────────────┘
```

1. **Dockerfile** — Ubuntu 24.04 base + [mise](https://mise.jdx.dev) copied in via multi-stage build. Activates mise in bash/zsh.
2. **scripts/setup** — `postCreateCommand` that trusts and installs tools from `mise.toml`.
3. **mise.toml** — Declarative tool list (no version pinning, always `latest`).

## Containers

| Use case | Path | Tools |
|----------|------|-------|
| Homelab / Kubernetes | `homelab/` | talosctl, kubectl, k9s, helm, kustomize, flux2, sops, age, cilium-cli |
| Terraform / Azure | `terraform-azure/` | terraform, terraform-docs, azure-cli, python, pipx |

## Podman Compatibility

Both devcontainers include:

- `--userns=keep-id` — maps host UID into the container
- SELinux `:Z` bind mounts — allows Podman rootless access

## Usage

Open a subfolder in VS Code, select **Reopen in Container**, done.
