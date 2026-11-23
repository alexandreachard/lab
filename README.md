# lab

[![terraform-validate](https://github.com/alexandreachard/lab/actions/workflows/terraform-validate.yml/badge.svg)](https://github.com/alexandreachard/lab/actions/workflows/terraform-validate.yml)

Terraform and runbooks from my work (sanitized), my homelab, and what I'm learning.

- **[work](work)**: patterns and setups I built on the job, sanitized (no names, IDs or real addresses).
- **[homelab](homelab)**: runbooks from my K3s cluster, [k3s-gitops-homelab](https://github.com/alexandreachard/k3s-gitops-homelab).
- **[learning](learning)**: things I built to learn.

## Work

| Item | What it is | Status |
| :-- | :-- | :-- |
| [azure-governance](work/azure-governance) | Management groups, team access with Entra groups, Allowed locations policy | Validated |
| [azure-private-endpoints](work/azure-private-endpoints) | One Private Endpoint per service from a map, with the DNS zone links | From production |
| [terraform-modules](work/terraform-modules) | Modules for Container Apps, networking, Private DNS Zones, Private Endpoints | From production |
| [azure-rag-network-isolation](work/azure-rag-network-isolation) | Network isolation of a RAG architecture with Private Endpoints | From production |
| [azure-subscription-manager](work/azure-subscription-manager) | PowerShell: batch rename subscriptions and move them into management groups | Used once (~50 subscriptions) |
| [gcp-network-edge](work/gcp-network-edge) | Site-to-site IPsec VPN to on-prem, VPC firewall rules, private VM with IAP and OS Login | From production |
| [gcp-mig-lb-cloud-armor](work/gcp-mig-lb-cloud-armor) | Reverse proxy MIG behind an HTTPS load balancer, Cloud Armor IP allowlist | From production |
| [netbox](work/netbox) | NetBox prefixes and aggregates managed with Terraform, and updating a containerized NetBox | From production |

## Homelab

| Item | What it is | Status |
| :-- | :-- | :-- |
| [renovate-cronjob](homelab/renovate-cronjob) | Self-hosted Renovate as a Kubernetes CronJob, with Flux and SOPS | Running |
| [traefik-ingress-tls](homelab/traefik-ingress-tls) | Exposing services on K3s with Traefik and TLS | Outdated: moving to cert-manager |
| [cloudflare-tunnel](homelab/cloudflare-tunnel) | Public access through Cloudflare Tunnel, no open port | Running |

## Learning

| Item | What it is |
| :-- | :-- |
| [terraform-state-refactoring](learning/terraform-state-refactoring) | Refactoring with `moved {}` and `removed {}` blocks instead of `terraform state` commands (Terraform Associate prep) |
| [azure-blob-uploader](learning/azure-blob-uploader) | Containerized script to upload files to Blob Storage |
| [kubernetes-first-steps](learning/kubernetes-first-steps) | My first manifests (nginx, linkding, mealie, Prometheus/Grafana with Helm), before the GitOps cluster |
| [docker](learning/docker) | Compose sandboxes: healthchecks, networking, persistence, reverse proxy... |
| [bash](learning/bash) | Bash course exercises |
| [devcontainers](learning/devcontainers) | Devcontainer with mise |
