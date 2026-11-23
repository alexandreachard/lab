resource "google_compute_firewall" "allow-mqtt-lb" {
  name      = "allow-mqtt-lb"
  network   = var.network
  project   = var.project_id
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["8883"]
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"] # Google health check and load balancer proxy ranges
  target_tags   = ["tcp-lb-mqtt"]
}

resource "google_compute_firewall" "allow-ssh-ingress-from-iap-to-vm" {
  name      = "allow-ssh-ingress-from-iap-to-vm"
  network   = var.network
  project   = var.project_id
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges           = ["35.235.240.0/20"]
  target_service_accounts = [var.vm_service_account_email]
}