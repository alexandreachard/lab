# Cloudflare Tunnel on Kubernetes

Public access to some homelab apps without opening a port on my router: `cloudflared` runs in the cluster (2 replicas) and only makes outbound connections to Cloudflare.

## Why

I wanted a few apps reachable from outside without exposing my home IP or opening ports. With a tunnel, TLS ends at Cloudflare and the cluster only talks outbound.

## Files in my cluster

One tunnel per app, in the app folder of [k3s-gitops-homelab](https://github.com/alexandreachard/k3s-gitops-homelab/tree/main/apps/staging). Example with audiobookshelf:

- [cloudflare.yaml](https://github.com/alexandreachard/k3s-gitops-homelab/blob/main/apps/staging/audiobookshelf/cloudflare.yaml): Deployment (2 replicas, probes on `/ready`) and the ConfigMap with `config.yaml`
- [cloudflare-secret.yaml](https://github.com/alexandreachard/k3s-gitops-homelab/blob/main/apps/staging/audiobookshelf/cloudflare-secret.yaml): tunnel credentials, encrypted with SOPS

## What I learned

- `cert.pem` (from `cloudflared tunnel login`) can create, delete and manage all the tunnels of the account: it stays on my laptop, never in Git or in the cluster. The `<UUID>.json` credentials file can only run that one tunnel: that's what goes in the Secret.
- Each replica opens 4 connections, to at least 2 Cloudflare data centers. Replicas are for availability, not load balancing, and Cloudflare doesn't recommend autoscaling: removing a replica cuts its connections.
- Outbound port 7844 must be open in UDP (QUIC) and TCP (HTTP/2).
- The image is distroless (no shell, no curl): to check `/ready`, use `kubectl port-forward`, not `kubectl exec`.

## Create a tunnel

```sh
cloudflared tunnel login                          # writes ~/.cloudflared/cert.pem
cloudflared tunnel create audiobookshelf          # writes <UUID>.json
cloudflared tunnel route dns audiobookshelf app.example.com
```

Put `<UUID>.json` in the Secret, encrypt it with SOPS, commit: Flux applies it.

## Check

```sh
kubectl -n audiobookshelf get pods -l app=cloudflared
kubectl -n audiobookshelf logs -l app=cloudflared | grep "Registered tunnel connection"
kubectl -n audiobookshelf port-forward deploy/cloudflared 2000:2000 &
curl -s localhost:2000/ready
```
