# GCP MIG + Load Balancer + Cloud Armor

Reverse proxy VMs in a Managed Instance Group, behind a global HTTPS load balancer, with a Cloud Armor policy that only lets known IPs in.

## Why

This reverse proxy was the front door to a web application running on private VMs. Users go through the load balancer, Cloud Armor filters the source IPs, and the proxy VMs forward to the application.

## What I learned

- Cloud Armor: the default rule has the lowest priority (2147483647). Here it denies, and a rule above it allows the listed ranges. In basic mode a rule takes 10 IP ranges max.
- Don't put a fixed internal IP in the instance template of a MIG: one IP can't go to several VMs. To keep a VM's IP across recreations, GCP has stateful IPs.
- The backend timeout defaults to 30 seconds. It's set to 24 h here for long requests, but Google doesn't guarantee the TCP connection stays open that long.
- CMEK disks: the KMS key role (`cryptoKeyEncrypterDecrypter`) goes to the Compute Engine service agent (`service-<PROJECT_NUMBER>@compute-system.iam.gserviceaccount.com`), not to the VM service account.
- Session affinity `CLIENT_IP` sends a client to the same VM. Google says to use the UTILIZATION balancing mode only with affinity `NONE`.
- The modules are pinned to old versions (vm 8.0.0, lb-http 6.x), so the google provider is stuck below 5. Upgrading to lb-http 14 changes the module interface.

## Run it

```sh
terraform init
terraform plan -var-file=terraform.tfvars
```

Most variables have no default (project, subnetwork, KMS key, image, sizing, certificates, allowed IPs).
