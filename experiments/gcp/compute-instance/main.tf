resource "google_service_account" "mytestvm-sa" {
  account_id   = "mytestvm-sa"
  display_name = "Service Account for mytestvm dev instance"
  project      = var.project_id
}

data "google_compute_disk" "mytestvm-disk" {
    name = "mytestvm-disk"
    zone = var.zone
    project = var.project_id
}

resource "google_compute_instance" "mytestvm" {
  name = "mytestvm"
  hostname     = "mytestvm.dev.local"
  project      = var.project_id
  zone         = var.zone
  machine_type = "e2-micro"
  labels = {
    "environnement" = "dev"
  }
  network_interface {
    subnetwork = var.subnetwork
    network_ip = "10.231.57.2"
  }
  scheduling {
    automatic_restart = false
  }
  boot_disk {
    kms_key_self_link = var.disk_encryption_key
    initialize_params {
      image = "debian-cloud/debian-11"
      size = 20
      type = var.disk_type
      }
  }
  service_account {
    email  = google_service_account.mytestvm-sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  metadata = {
    "enable-oslogin" = "true"
    "ssh-keys"       = "mynewuser:ssh-rsa AAAAxxxxxxxxxxxx mynewuser"
  }
}