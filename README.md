# Lab

Personal engineering lab for prototyping, testing, breaking, and documenting cloud infrastructure, automation, and platform engineering patterns.

---

## What's Inside

### 🧱 Patterns
Reusable infrastructure patterns and reference architectures refined from real-world implementations:
- **[Terraform Modern State Refactoring](patterns/terraform-state-refactoring)** — Zero-downtime refactoring and declarative unmanagement using native HCL `moved {}` (TF 1.1+) and `removed {}` (TF 1.7+) blocks on Azure workloads.
- **[Azure Enterprise Governance](patterns/azure-enterprise-governance)** — Management group hierarchy, policy assignments, and subscription-level governance controls.
- **[Private Endpoint Factory](patterns/private-endpoint-factory)** — Modular Terraform pattern for provisioning Azure Private Endpoints with automated Private DNS Zone integration.
- **[Terraform Modules](patterns/terraform-modules)** — Reusable modules for Azure Container Apps (ACA), virtual networking, Private DNS Zones, and Private Endpoints.

### 🧪 Experiments
Hands-on explorations of cloud services, security boundaries, and infrastructure prototypes:
- **[Azure RAG Network Isolation](experiments/azure-rag-network-isolation)** — Securing Retrieval-Augmented Generation architectures with Private Endpoints and strict network perimeter isolation.
- **[GCP Classic VPN](experiments/gcp-classic-vpn)** — Site-to-site IPsec VPN connectivity on Google Cloud Platform.
- **[GCP Compute & Networking](experiments/gcp-compute-instance)** — Compute instances, custom firewall rules, and Managed Instance Groups (MIG) behind load balancers.
- **[Netbox](experiments/netbox)** — Network Source of Truth (NSoT) deployment and testing.

### 📖 Runbooks
Operational procedures and repeatable production guides documented as code:
- **[Renovate Bot Kubernetes CronJob](runbooks/kubernetes-renovate-cronjob)** — Self-hosted Renovate bot running as a native Kubernetes `CronJob`, automated with FluxCD and secured with Mozilla SOPS/Age.
- **[K3s Traefik Ingress & TLS](runbooks/k3s-traefik-ingress-tls)** — Internal service exposition on K3s using native Traefik, namespace-scoped TLS certificates, SAN generation, and local DNS resolution.
- **[HA Cloudflare Tunnels on Kubernetes](runbooks/cloudflare-tunnels-kubernetes)** — Outbound-only, zero-open-port public exposition using high-availability (2 replicas, 8 Anycast connections) `cloudflared` agents.
- **[Netbox Updates](runbooks/netbox-updates)** — Maintenance and container update workflows for Netbox instances.

### 🛠️ Tools
Lightweight utilities built to solve specific platform engineering operational challenges:
- **[Azure Subscription Batch Manager](tools/azure-subscription-manager)** — PowerShell automation to batch rename and migrate Azure subscriptions into target Management Groups without Tenant Root Group admin rights.
- **[Azure Blob Uploader](tools/azure-blob-uploader)** — Containerized CLI tool for automated uploads to Azure Blob Storage containers.

### 💻 Snippets
Quick-reference snippets and foundational learning sandboxes:
- **Bash** — Scripting fundamentals and automation patterns.
- **Dev Containers** — Standardized containerized developer environments managed with `mise`.
- **Docker** — Multi-container stacks, healthchecks, networking, and reverse proxy patterns.
- **Kubernetes Playground** — Application manifests and foundational cluster configurations.

---

## Technical Stack

- **IaC & Automation:** Terraform (HCL), FluxCD (GitOps), Mozilla SOPS, Age, Kustomize, Helm
- **Cloud & Virtualization:** Microsoft Azure, Google Cloud Platform (GCP), Kubernetes (K3s), Docker
- **Networking & Security:** Traefik, Cloudflare Tunnels (`cloudflared`), WireGuard, Private Endpoints, DNS
- **Languages & Scripting:** Bash, PowerShell, Python

---

## Purpose

This lab is where I prototype, validate, and stress-test infrastructure patterns before applying them to production or portfolio repositories (such as [`dell-cluster`](https://github.com/alexandreachard/dell-cluster)). It reflects a hands-on platform craftsmanship philosophy: understanding system mechanics from the kernel to the cloud control plane.
