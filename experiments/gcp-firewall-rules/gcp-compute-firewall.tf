resource "google_compute_firewall" "allow-mqtt-lb" {
  name      = "allow-mqtt-lb"
  network   = "my-prod-spoke-0"
  project   = "my-net-spoke-prod-0"
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["8883"]
  }

  source_ranges = ["35.191.0.0/16","130.211.0.0/22"] #GCP Global external Application Load Balancer ips
  target_tags = ["tcp-lb-mqtt"]
}

resource "google_compute_firewall" "allow-ssh-ingress-from-iap-to-vm" {
  name      = "allow-ssh-ingress-from-iap-to-vm"
  network   = "my-prod-spoke-0"
  project   = "my-net-spoke-prod-0"
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges           = ["35.235.240.0/20"]
  target_service_accounts = ["${google_service_account.my-vm-sa.email}"]
}