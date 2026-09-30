# Runbook: K3s Service Exposition with Traefik Ingress and TLS

Expose internal Kubernetes workloads on the local network (LAN) using K3s native **Traefik Ingress Controller** with TLS termination and local DNS resolution.

---

## Architecture

```
                       Client LAN Request
                                │
               https://app.homelab.local (Port 443)
                                │
                                ▼
                   [ Local DNS (AdGuard / LAN) ]
                                │ Resolves to K3s Node LAN IP
                                ▼
            ┌─────────────────────────────────────────┐
            │ K3s Node Host (Ports 80 & 443)          │
            │                                         │
            │   ┌───────────────────────────────────┐ │
            │   │ Pod: Traefik Ingress Controller   │ │
            │   │ - Listens on web (80) & websecure │ │
            │   │ - Terminates TLS via Secret       │ │
            │   │ - Host header routing             │ │
            │   └───────────────┬───────────────────┘ │
            │                   │ Host match          │
            │                   ▼                     │
            │           [ ClusterIP Service ]         │
            │                   │                     │
            │                   ▼                     │
            │             [ Target Pod ]              │
            └─────────────────────────────────────────┘
```

---

## Directory Structure

```
runbooks/k3s-traefik-ingress-tls/
├── manifests/
│   ├── ingress-traefik.yaml
│   └── tls-secret-template.yaml
├── scripts/
│   └── generate-selfsigned-cert.sh
└── README.md
```

---

## Prerequisites

- K3s cluster with default Traefik Ingress enabled (`traefik (default)` ingress class).
- Local DNS server (AdGuard Home, Pi-hole, or local `/etc/hosts`) resolving hostnames to the K3s host IP.
- OpenSSL (optional, if generating self-signed certificates).

---

## Step-by-Step Implementation

### 1. Generate Certificates & Create the TLS Secret

#### Option A: Self-Signed Certificate via Script

```bash
./scripts/generate-selfsigned-cert.sh homelab.local
```

Create the Kubernetes Secret:

```bash
kubectl create secret tls app-tls-secret \
  --cert=certs/tls.crt \
  --key=certs/tls.key \
  --namespace <target-namespace>
```

#### Option B: Declarative / GitOps with SOPS

Fill `manifests/tls-secret-template.yaml` with your base64-encoded certificate and private key, then encrypt:

```bash
sops --encrypt --in-place \
  --encrypted-regex '^(data|stringData)$' \
  manifests/tls-secret-template.yaml
```

> **Strict Rule (CKA / K8s Core):** A Kubernetes Ingress resource can **only** reference a TLS Secret located in the **same namespace** as the Ingress itself. Cross-namespace secret references are forbidden by Kubernetes core design.

### 2. Deploy the Ingress Resource

Adjust `manifests/ingress-traefik.yaml` to match your service and namespace:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  namespace: <target-namespace>
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: web,websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
spec:
  ingressClassName: traefik
  tls:
    - hosts:
        - app.homelab.local
      secretName: app-tls-secret
  rules:
    - host: app.homelab.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: app-service
                port:
                  number: 8080
```

Apply the manifest:

```bash
kubectl apply -f manifests/ingress-traefik.yaml
```

### 3. Local DNS Configuration

Add a DNS `A` record on your local DNS server (e.g., AdGuard Home):

| Domain | Record Type | Target IP | Description |
| :--- | :--- | :--- | :--- |
| `app.homelab.local` | `A` | `192.168.x.x` | Points to K3s Host IP |

---

## Validation Commands

```bash
# 1. Verify IngressClass is active
kubectl get ingressclass

# 2. Inspect Ingress status and assigned host
kubectl get ingress -n <target-namespace>
kubectl describe ingress app-ingress -n <target-namespace>

# 3. Test DNS resolution
dig +short app.homelab.local @<DNS_IP>

# 4. Validate HTTP response & TLS handshake
curl -vkI https://app.homelab.local --resolve app.homelab.local:443:<K3S_NODE_IP>
```

---

## Troubleshooting

| Symptom | Cause | Solution |
| :--- | :--- | :--- |
| **HTTP 404 Not Found from Traefik** | The `Host:` HTTP header sent by the client does not match `spec.rules[].host`. | Verify DNS resolves correctly and matches the Ingress rule host. |
| **HTTP 502 Bad Gateway** | Target service or pod is down, or target port is incorrect. | Run `kubectl get endpoints -n <namespace>` and check if backend pods are healthy. |
| **Certificate Warning (Traefik Default Cert)** | Secret name is incorrect, secret is missing, or secret is in another namespace. | Ensure the Secret exists in the **same namespace** as the Ingress. |
| **SSL Handshake Failed / Connection Refused** | Host ports 80/443 are blocked by firewall on the K3s host. | Verify OS firewall (`ufw`, `iptables`, `firewalld`) allows incoming traffic on ports 80 and 443. |
