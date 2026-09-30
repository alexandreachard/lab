# Runbooks

Operational procedures, maintenance guides, and repeatable production workflows documented as code.

---

## Available Runbooks

| Runbook | Focus Area | Key Concepts |
| :--- | :--- | :--- |
| **[Renovate Bot Kubernetes CronJob](kubernetes-renovate-cronjob)** | Automation & GitOps | Self-hosted bot, Kubernetes CronJob, SOPS/Age, `concurrencyPolicy: Forbid` |
| **[K3s Traefik Ingress & TLS](k3s-traefik-ingress-tls)** | Networking & TLS | K3s native Traefik, namespace-scoped TLS Secrets, SAN certs, local DNS |
| **[HA Cloudflare Tunnels on K8s](cloudflare-tunnels-kubernetes)** | Security & Edge Networking | High-availability `cloudflared` (2 replicas), outbound-only, zero open ports |
| **[Netbox Updates](netbox-updates)** | Infrastructure Operations | Production maintenance, container rebuilds, and plugin updates |
