#reverse proxy instance with lb and cloud armor
resource "google_service_account" "prod-rp-sa" {
  account_id   = "prod-rp-sa"
  display_name = "Service Account for prod - rp instance"
  project      = var.project_id
}

resource "google_kms_crypto_key_iam_member" "crypto_key" {
  crypto_key_id = var.disk_encryption_key
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.prod-rp-sa.email}"
}

module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = "8.0.0"

  region = var.region
  project_id = var.project_id

  machine_type   = var.machine_type
  tags           = ["allow-shared-vpc-mig"]
  labels         = var.labels
  startup_script = var.startup_script
  metadata       = var.metadata
  # metadata_startup_script = var.startup_script
  service_account = {
    email  = google_service_account.prod-rp-sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  /* network */
  subnetwork         = var.subnetwork
  subnetwork_project = var.subnetwork_project
  can_ip_forward     = var.can_ip_forward
  network_ip         = "10.231.57.10"

  /* image */
  source_image         = var.source_image
  source_image_family  = var.source_image_family
  source_image_project = var.source_image_project

  /* disks */
  disk_size_gb        = var.disk_size_gb
  disk_type           = var.disk_type
  disk_labels         = var.disk_labels
  disk_encryption_key = var.disk_encryption_key
  auto_delete         = var.auto_delete
  additional_disks    = var.additional_disks
}

# Create a Managed Instance Group from the  previous Instance template
# Managed Instance Group
module "mig" {
  source  = "terraform-google-modules/vm/google//modules/mig"
  version = "8.0.0"

  # Service Project ID
  project_id                = var.project_id
  hostname                  = var.hostname
  region                    = var.region
  instance_template         = module.instance_template.self_link
  target_size               = var.target_size
  target_pools              = var.target_pools
  distribution_policy_zones = var.distribution_policy_zones
  update_policy             = var.update_policy
  named_ports               = var.named_ports

  /* health check */
  health_check = var.health_check

  /* autoscaler */
  autoscaling_enabled          = var.autoscaling_enabled
  max_replicas                 = var.max_replicas
  min_replicas                 = var.min_replicas
  cooldown_period              = var.cooldown_period
  autoscaling_cpu              = var.autoscaling_cpu
  autoscaling_metric           = var.autoscaling_metric
  autoscaling_lb               = var.autoscaling_lb
  autoscaling_scale_in_control = var.autoscaling_scale_in_control
}

# Create a Load Balancer, that uses the previous Managed Instance Group
# as a backend
module "gce-lb-http" {
  source            = "GoogleCloudPlatform/lb-http/google"
  version           = "~> 6.0"
  name              = "group-http-lb-prod"
  project           = var.project_id
  target_tags       = ["allow-shared-vpc-mig"]
  firewall_projects = [var.host_project]
  firewall_networks = [var.network]
  ssl                  = var.ssl
  ssl_certificates     = var.ssl_certificates
  use_ssl_certificates = var.use_ssl_certificates

  backends = {
    default = {
      description                     = null
      protocol                        = "HTTPS"
      port                            = 443
      port_name                       = "https"
      timeout_sec                     = 86400
      connection_draining_timeout_sec = null
      enable_cdn                      = false
      security_policy                 = google_compute_security_policy.allow_source_ips.self_link
      session_affinity                = "CLIENT_IP"
      affinity_cookie_ttl_sec         = null
      custom_request_headers          = null
      custom_response_headers         = null

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/"
        port                = 443
        host                = null
        logging             = null
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          group                        = module.mig.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = 0.95
        }
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
    }
  }
}

# Cloud Armor policy

resource "google_compute_security_policy" "allow_source_ips" {
  name = "gke-backend-allow-source-ips"

  project = var.project_id

  rule {
    action   = "allow"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = var.allow_source_ips
      }
    }
    description = "Allow access for testing"
  }

  rule {
    action   = "deny(403)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"] #allow specific public ip at first
      }
    }
    description = "Default rule"
  }
}
