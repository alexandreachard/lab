# Traefik Ingress with cert-manager (DNS-01)

TLS for the apps of my K3s cluster (homepage, linkding, grafana): Traefik is the Ingress controller, cert-manager gets Let's Encrypt certificates with the DNS-01 challenge on Cloudflare and renews them.

## Why

At first I made a self-signed certificate with OpenSSL and created the TLS Secret by hand: browser warnings, and a renewal to remember. With DNS-01, Let's Encrypt checks a TXT record in Cloudflare, so the apps get trusted certificates without opening port 80 on my router.

## Files in my cluster

In [k3s-gitops-homelab](https://github.com/alexandreachard/k3s-gitops-homelab), applied by Flux:

- [cert-manager release.yaml](https://github.com/alexandreachard/k3s-gitops-homelab/blob/main/infrastructure/controllers/base/cert-manager/release.yaml): HelmRelease v1.19.1, with the CRDs
- [cluster-issuers.yaml](https://github.com/alexandreachard/k3s-gitops-homelab/blob/main/infrastructure/configs/base/cert-manager/cluster-issuers.yaml): `letsencrypt-staging` and `letsencrypt-prod`, DNS-01 Cloudflare solver
- [cloudflare-api-token-secret.yaml](https://github.com/alexandreachard/k3s-gitops-homelab/blob/main/infrastructure/configs/staging/cert-manager/cloudflare-api-token-secret.yaml): Cloudflare API token, encrypted with SOPS
- [linkding ingress.yaml](https://github.com/alexandreachard/k3s-gitops-homelab/blob/main/apps/staging/linkding/ingress.yaml): an Ingress that asks for a certificate

The Ingress only needs the annotation and a `tls` section:

```yaml
metadata:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: traefik
  tls:
    - hosts:
        - ${LINKDING_HOST}    # replaced by Flux, the real hostname isn't in Git
      secretName: linkding-tls
```

## What I learned

- With the `cluster-issuer` annotation, cert-manager creates a `Certificate` named after `secretName`, in the namespace of the Ingress, and the Secret lands there too.
- A ClusterIssuer reads its Secrets in the cert-manager namespace by default: that's where the Cloudflare token goes, not in the app namespace.
- The Cloudflare token needs Zone / DNS / Edit and Zone / Zone / Read.
- Test with the staging issuer first: same kind of rate limits but higher, and its certificates aren't trusted by browsers.
- Certificates last 90 days, cert-manager renews them at 2/3 of that (30 days before expiry).
- My first token had lost a character in a copy-paste: Cloudflare answered `9109: Invalid access token`. `kubectl describe` on the Certificate, CertificateRequest, Order and Challenge shows where it's stuck.

## Check

```sh
kubectl -n linkding get certificate
kubectl -n linkding describe certificate linkding-tls
kubectl -n linkding get order,challenge
```
