# lab

Terraform patterns, experiments, runbooks and small tools from my work and my homelab.

- **Work**: patterns and setups I built on the job, sanitized (no names, IDs or real addresses).
- **Homelab**: runbooks from my K3s cluster, [dell-cluster](https://github.com/alexandreachard/dell-cluster).
- **Lab / exercise**: things I built to learn.

## Patterns

| Item | What it is | Origin |
| :-- | :-- | :-- |
| [azure-enterprise-governance](patterns/azure-enterprise-governance) | Management group hierarchy and policy assignments | Work |
| [private-endpoint-factory](patterns/private-endpoint-factory) | Private Endpoints with Private DNS Zone integration | Work |
| [terraform-modules](patterns/terraform-modules) | Modules for Container Apps, networking, Private DNS Zones, Private Endpoints | Work |
| [terraform-state-refactoring](patterns/terraform-state-refactoring) | Refactoring with `moved {}` and `removed {}` blocks instead of `terraform state` commands | Lab (Terraform Associate prep) |

## Experiments

| Item | What it is | Origin |
| :-- | :-- | :-- |
| [azure-rag-network-isolation](experiments/azure-rag-network-isolation) | Network isolation of a RAG architecture with Private Endpoints | Work |
| [gcp-classic-vpn](experiments/gcp-classic-vpn) | Site-to-site IPsec VPN on GCP | Work |
| [gcp-compute-instance](experiments/gcp-compute-instance) | Compute Engine instances | Work |
| [gcp-firewall-rules](experiments/gcp-firewall-rules) | VPC firewall rules | Work |
| [gcp-mig-with-lb](experiments/gcp-mig-with-lb) | Managed Instance Group behind a load balancer | Work |
| [netbox](experiments/netbox) | NetBox prefixes and aggregates managed with Terraform | Work |
| [k8s-basics](experiments/k8s-basics) | First Pods and Deployments, rollout strategies | Exercise |

## Runbooks

| Item | What it is | Origin |
| :-- | :-- | :-- |
| [kubernetes-renovate-cronjob](runbooks/kubernetes-renovate-cronjob) | Self-hosted Renovate as a Kubernetes CronJob, with Flux and SOPS | Homelab |
| [k3s-traefik-ingress-tls](runbooks/k3s-traefik-ingress-tls) | Exposing services on K3s with Traefik and TLS | Homelab |
| [cloudflare-tunnels-kubernetes](runbooks/cloudflare-tunnels-kubernetes) | Public access through Cloudflare Tunnel, no open port | Homelab |
| [netbox-updates](runbooks/netbox-updates) | Updating a containerized NetBox | Work |

## Tools

| Item | What it is | Origin |
| :-- | :-- | :-- |
| [azure-subscription-manager](tools/azure-subscription-manager) | PowerShell: batch rename subscriptions and move them into management groups | Work |
| [azure-blob-uploader](tools/azure-blob-uploader) | Containerized script to upload files to Blob Storage | Lab |

## Snippets

Learning sandboxes: [bash](snippets/bash), [docker](snippets/docker) (healthchecks, networking, persistence, reverse proxy...),
[devcontainers](snippets/devcontainers) (mise), [kubernetes-playground](snippets/kubernetes-playground).
