resource "netbox_rir" "rfc-1918" {
  name = "RFC 1918"
  slug = "rfc-1918"
}

resource "netbox_rir" "apnic" {
  name = "APNIC"
  slug = "apnic"
}
resource "netbox_rir" "arin" {
  name = "ARIN"
  slug = "arin"
}
resource "netbox_rir" "rpie-ncc" {
  name = "RIPE NCC"
  slug = "rpie-ncc"
}


resource "netbox_aggregate" "rf1918-10" {
  prefix     = "10.0.0.0/8"
  rir_id     = netbox_rir.rfc-1918.id
  depends_on = [netbox_rir.rfc-1918]
}

resource "netbox_aggregate" "rf1918-172" {
  prefix     = "172.16.0.0/12"
  rir_id     = netbox_rir.rfc-1918.id
  depends_on = [netbox_rir.rfc-1918]
}

resource "netbox_aggregate" "rf1918-192" {
  prefix     = "192.168.0.0/16"
  rir_id     = netbox_rir.rfc-1918.id
  depends_on = [netbox_rir.rfc-1918]
}
