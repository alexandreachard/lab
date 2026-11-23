resource "google_compute_vpn_gateway" "target_gateway" {
  project = var.project_id
  name    = "vpn"
  network = var.network
  region  = var.region
}

resource "google_compute_address" "vpn_static_ip" {
  name        = "test-prod-wanip"
  description = "test-prod-wanip"
  project     = var.project_id
  region      = var.region
}

resource "google_compute_forwarding_rule" "fr_esp" {
  project     = var.project_id
  name        = "fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.target_gateway.id
  region      = var.region
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  project     = var.project_id
  name        = "fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.target_gateway.id
  region      = var.region
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  project     = var.project_id
  name        = "fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.target_gateway.id
  region      = var.region
}

resource "google_compute_vpn_tunnel" "tunnel1" {
  project       = var.project_id
  region        = var.region
  name          = "vpn-prod"
  peer_ip       = "w.x.y.z"
  shared_secret = "MySuperSharedSecretPassw0rd"

  target_vpn_gateway = google_compute_vpn_gateway.target_gateway.id

  local_traffic_selector  = ["10.231.57.0/22"]
  remote_traffic_selector = ["192.168.1.0/24"]

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500,
  ]
}

resource "google_compute_route" "route1" {
  name                = "vpn-prod"
  network             = var.network
  dest_range          = "192.168.1.0/24"
  priority            = 1000
  project             = var.project_id
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel1.id
}