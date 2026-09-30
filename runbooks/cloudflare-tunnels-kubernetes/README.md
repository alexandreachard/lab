# Runbook: High-Availability Cloudflare Tunnels on Kubernetes

Expose internal Kubernetes services securely to the internet without opening inbound firewall ports or configuring public IPs, using **Cloudflare Tunnels** (`cloudflared`) in a high-availability (2-replica) configuration.

---

## Architecture

```
                    Internet Web Client
                             │
                             ▼ HTTPS (TLS Termination at Cloudflare Edge)
                  [ Cloudflare Global Anycast ]
                             │
                             ▼ Encrypted Tunnel (QUIC / mTLS - Port 7844 UDP)
                    (Outbound Connection Only)
                             │
      ┌──────────────────────┼──────────────────────┐
      │                      │                      │
      ▼ Connection 1..4      ▼ Connection 5..8      │
┌──────────────┐      ┌──────────────┐              │
│ cloudflared  │      │ cloudflared  │              │
│   (Pod 1)    │      │   (Pod 2)    │              │
└──────┬───────┘      └──────┬───────┘              │
       │                     │                      │
       └──────────┬──────────┘                      │
                  ▼ HTTP over ClusterIP             │
         [ Internal App Service ]                   │
                  │                                 │
                  ▼                                 │
            [ Target Pod ]                          │
                                                    │
                 Kubernetes Cluster Private Network ┘
```

### Key Principles

1. **Outbound-Only (Egress) :** Pods initiate connections to Cloudflare Edge. Works seamlessly behind NAT, CGNAT (4G/5G/Fiber), and strict corporate firewalls.
2. **High Availability (HA) :** 2 replicas maintain 8 parallel persistent tunnels. If a pod crashes or a node reboots, Cloudflare instantly routes traffic to the remaining tunnels without downtime.
3. **Defense in Depth :** Public TLS termination and DDoS/WAF protection happen on Cloudflare Edge before traffic hits your cluster.

---

## Security: `cert.pem` vs `credentials.json`

| File | Scope | Privilege Level | Rule |
| :--- | :--- | :--- | :--- |
| **`cert.pem`** | Entire Cloudflare Account & DNS Zone | **Super Admin:** Can create, delete tunnels, and alter any DNS record. | **NEVER put in Git or Kubernetes.** Keep offline and purge from hosts after tunnel setup. |
| **`credentials.json`** | Specific Tunnel only (`TunnelID` + `TunnelSecret`) | **Least Privilege:** Can only connect to this specific tunnel. | Safe to inject into a Kubernetes Secret (encrypt with SOPS/Age for GitOps). |

---

## Directory Structure

```
runbooks/cloudflare-tunnels-kubernetes/
├── manifests/
│   ├── configmap.yaml
│   ├── deployment.yaml
│   └── secret-template.yaml
└── README.md
```

---

## Step-by-Step Setup

### 1. Authenticate and Create Tunnel (Host CLI)

```bash
# 1. Login to your Cloudflare account (generates ~/.cloudflared/cert.pem)
cloudflared tunnel login

# 2. Create the tunnel (generates <TUNNEL_UUID>.json)
cloudflared tunnel create <TUNNEL_NAME>

# 3. Route DNS hostname to tunnel target
cloudflared tunnel route dns <TUNNEL_NAME> app.example.com
```

### 2. Configure the Kubernetes Secret

Extract the content from `<TUNNEL_UUID>.json` into `manifests/secret-template.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: tunnel-credentials
  namespace: <target-namespace>
type: Opaque
stringData:
  credentials.json: |
    {
      "AccountTag": "...",
      "TunnelSecret": "...",
      "TunnelID": "..."
    }
```

Encrypt with Mozilla SOPS before committing to Git:

```bash
sops --encrypt --in-place \
  --encrypted-regex '^(data|stringData)$' \
  manifests/secret-template.yaml
```

> **Security Cleanup:** Remove `~/.cloudflared/cert.pem` from the machine once the tunnel is created.

### 3. Configure Routing in ConfigMap

Edit `manifests/configmap.yaml` to point your external domain to your internal `ClusterIP` service:

```yaml
data:
  config.yaml: |
    tunnel: <TUNNEL_UUID>
    credentials-file: /etc/cloudflared/creds/credentials.json
    metrics: 0.0.0.0:2000
    no-autoupdate: true

    ingress:
      - hostname: app.example.com
        service: http://app-service:8080
      - service: http_status:404
```

### 4. Deploy to Cluster

```bash
kubectl apply -f manifests/secret-template.yaml
kubectl apply -f manifests/configmap.yaml
kubectl apply -f manifests/deployment.yaml
```

---

## Validation & Operations

```bash
# 1. Verify 2 replicas are running
kubectl get pods -n <target-namespace> -l app.kubernetes.io/name=cloudflared

# 2. Check tunnel connection logs
kubectl logs -n <target-namespace> -l app.kubernetes.io/name=cloudflared -f

# Look for: "Registered tunnel connection connIndex=0..3"

# 3. Validate endpoint health probe
kubectl exec -n <target-namespace> deploy/cloudflared -c cloudflared -- curl -s http://localhost:2000/ready
```

---

## Troubleshooting

| Symptom | Cause | Solution |
| :--- | :--- | :--- |
| **HTTP 502 Bad Gateway** | `cloudflared` cannot reach internal Kubernetes service. | Check `service: http://<service-name>:<port>` in `config.yaml`. Verify Service and Target Pod are running in the same namespace or use FQDN (`<service>.<ns>.svc.cluster.local`). |
| **HTTP 530 / Error 1033** | Tunnel is disconnected or credentials are invalid. | Check pod logs (`kubectl logs`). Ensure `credentials.json` has valid `TunnelSecret` and `TunnelID`. |
| **Pod CrashLoopBackOff** | Missing volume mount or malformed `config.yaml`. | Run `kubectl describe pod` and verify ConfigMap / Secret volume mount paths match `config.yaml`. |
| **QUIC Connection Timeout** | Firewall blocks outbound UDP port 7844. | `cloudflared` will automatically fallback to HTTP/2 over TCP 443. To enforce HTTP/2, add `--protocol http2` to `args`. |
