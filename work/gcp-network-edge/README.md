# GCP Network Edge

Terraform for the edge of a GCP spoke network: a site-to-site IPsec VPN to on-prem, VPC firewall rules, and a private VM to test them.

- `vpn/`: Classic VPN gateway, static IP, the 3 forwarding rules (ESP, UDP 500, UDP 4500), a policy-based tunnel and the route to on-prem.
- `firewall/`: MQTT (TCP 8883) from Google health check ranges to the load balanced VMs, SSH only from IAP to one service account.
- `compute-instance/`: VM with no public IP, its own service account, a CMEK boot disk, a static internal IP and OS Login.

## Why

I build the GCP landing zones with Terraform, with network spoke projects. These pieces come from a production spoke:
- a site-to-site VPN to the on-prem datacenter;
- MQTT over TLS (8883) behind a load balancer, to collect data from industrial machines;
- admin SSH through IAP, so no VM needs a public IP;
- a test VM to check the firewall rules and the VPN.

## What I learned

- Classic VPN with static routing is still supported, only BGP on Classic VPN is deprecated (since August 2025). Google recommends HA VPN, which needs BGP.
- Classic VPN needs the 3 forwarding rules to the gateway, HA VPN doesn't.
- With a policy-based tunnel, the console creates the route to the remote range. With Terraform or gcloud you create it yourself (`google_compute_route` with `next_hop_vpn_tunnel`).
- SSH through IAP: allow `35.235.240.0/20` on port 22, no public IP needed on the VM.
- With OS Login enabled, SSH keys in metadata are no longer accepted.

## Run it

Each folder is a separate root module:

```sh
cd vpn    # or firewall, compute-instance
terraform init
terraform plan
```

Variables have no defaults: pass them with a `terraform.tfvars`. `shared_secret` is sensitive, don't commit it.
