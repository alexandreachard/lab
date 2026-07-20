# Module: Reverse Proxy Infrastructure (MIG + HTTP(S) LB + Cloud Armor)

In this experiment, I provision a highly scalable, secure reverse proxy architecture on Google Cloud Platform. I string together an Instance Template (using a dedicated service account and KMS integration), a Managed Instance Group (MIG), an External HTTP(S) Load Balancer with custom health checks, and a Cloud Armor Security Policy acting as a web application firewall perimeter.

## Usage

I use this pattern to build a production-ready edge routing layer that scales automatically based on incoming request metrics while protecting my backend servers from unapproved external IP addresses:

```hcl
module "secure_reverse_proxy" {
  source = "../modules/secure_reverse_proxy"

  project_id           = "gcp-platform-prod-001"
  host_project         = "gcp-network-hub-001"
  region               = "europe-west1"
  network              = "vpc-prod-shared-001"
  subnetwork           = "projects/gcp-network-hub-001/regions/europe-west1/subnetworks/snet-prod-rp-001"
  disk_encryption_key  = "projects/gcp-platform-prod-001/locations/europe-west1/keyRings/kr-prod/cryptoKeys/key-disk-rp"
  allow_source_ips     = ["1.2.3.4/24", "1.2.3.4/32"]
  
  # Instance configuration
  machine_type         = "e2-medium"
  target_size          = 2
  min_replicas         = 2
  max_replicas         = 5
}