# lab

[![terraform-validate](https://github.com/alexandreachard/lab/actions/workflows/terraform-validate.yml/badge.svg)](https://github.com/alexandreachard/lab/actions/workflows/terraform-validate.yml)

Terraform patterns, experiments, runbooks and small tools from my work and my homelab.

- **[work](work)**: patterns and setups I built on the job, sanitized (no names, IDs or real addresses).
- **[homelab](homelab)**: runbooks from my K3s cluster, [k3s-gitops-homelab](https://github.com/alexandreachard/k3s-gitops-homelab).
- **[learning](learning)**: things I built to learn.

## Work

| Item | What it is |
| :-- | :-- |
| [azure-governance](work/azure-governance) | Management group hierarchy and policy assignments |
| [azure-private-endpoints](work/azure-private-endpoints) | Private Endpoints with Private DNS Zone integration |
| [terraform-modules](work/terraform-modules) | Modules for Container Apps, networking, Private DNS Zones, Private Endpoints |
| [azure-rag-network-isolation](work/azure-rag-network-isolation) | Network isolation of a RAG architecture with Private Endpoints |
| [azure-subscription-manager](work/azure-subscription-manager) | PowerShell: batch rename subscriptions and move them into management groups |
| [gcp-network-edge](work/gcp-network-edge) | Site-to-site IPsec VPN, VPC firewall rules and Compute Engine instances on GCP |
| [gcp-mig-lb-cloud-armor](work/gcp-mig-lb-cloud-armor) | Managed Instance Group behind a load balancer |
| [netbox](work/netbox) | NetBox prefixes and aggregates managed with Terraform, and updating a containerized NetBox |

## Homelab

| Item | What it is |
| :-- | :-- |
| [renovate-cronjob](homelab/renovate-cronjob) | Self-hosted Renovate as a Kubernetes CronJob, with Flux and SOPS |
| [traefik-ingress-tls](homelab/traefik-ingress-tls) | Exposing services on K3s with Traefik and TLS |
| [cloudflare-tunnel](homelab/cloudflare-tunnel) | Public access through Cloudflare Tunnel, no open port |

## Learning

| Item | What it is |
| :-- | :-- |
| [terraform-state-refactoring](learning/terraform-state-refactoring) | Refactoring with `moved {}` and `removed {}` blocks instead of `terraform state` commands (Terraform Associate prep) |
| [azure-blob-uploader](learning/azure-blob-uploader) | Containerized script to upload files to Blob Storage |
| [kubernetes-first-steps](learning/kubernetes-first-steps) | My first manifests (nginx, linkding, mealie, Prometheus/Grafana with Helm), before the GitOps cluster |
| [docker](learning/docker) | Compose sandboxes: healthchecks, networking, persistence, reverse proxy... |
| [bash](learning/bash) | Bash course exercises |
| [devcontainers](learning/devcontainers) | Devcontainer with mise |
