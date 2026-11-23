# Devcontainer with mise

The devcontainer I start from: Ubuntu 24.04 with [mise](https://mise.jdx.dev) installing the tools pinned in `mise.toml` (Terraform, Azure CLI, kubectl, Helm, Flux, SOPS, age...). Nothing to install on the host, same versions everywhere. Works with Podman (SELinux `:Z`, `--userns=keep-id`).
