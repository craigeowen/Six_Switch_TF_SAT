# Example: Loopbacks on both switches
resource "nxos_loopback_interface" "sat01_lo" {
  provider = nxos.sat01
  for_each = var.loopbacks_sat01

  interface_id = "loopback${replace(each.key, "lo", "")}"
  admin_state  = "up"
  description  = "${var.pair_name}-${each.key}"

  ipv4 = [{
    address = "${each.value.ip}/32"
  }]
}

resource "nxos_loopback_interface" "sat02_lo" {
  provider = nxos.sat02
  for_each = var.loopbacks_sat02

  interface_id = "loopback${replace(each.key, "lo", "")}"
  admin_state  = "up"
  description  = "${var.pair_name}-${each.key}"

  ipv4 = [{
    address = "${each.value.ip}/32"
  }]
}

# Example: SVIs on both switches
resource "nxos_svi_interface" "sat01_svi" {
  provider = nxos.sat01
  for_each = var.svis_sat01

  interface_id = "vlan${replace(each.key, "vlan", "")}"
  admin_state  = "up"
  description  = "${var.pair_name}-${each.key}"

  ipv4 = [{
    address = "${each.value.ip}/${split("/", each.value.subnet_cidr)[1]}"
  }]
}

resource "nxos_svi_interface" "sat02_svi" {
  provider = nxos.sat02
  for_each = var.svis_sat02

  interface_id = "vlan${replace(each.key, "vlan", "")}"
  admin_state  = "up"
  description  = "${var.pair_name}-${each.key}"

  ipv4 = [{
    address = "${each.value.ip}/${split("/", each.value.subnet_cidr)[1]}"
  }]
}

# Example: P2P routed link between sat01 and sat02
resource "nxos_ipv4_interface" "sat01_ptp" {
  provider = nxos.sat01
  for_each = var.ptp_links

  interface_id = "Ethernet1/${replace(each.key, "ptp", "")}" # or map name->intf in another var
  vrf_name     = "default"

  address = "${each.value.sat01_ip}/${split("/", each.value.subnet_cidr)[1]}"
}

resource "nxos_ipv4_interface" "sat02_ptp" {
  provider = nxos.sat02
  for_each = var.ptp_links

  interface_id = "Ethernet1/${replace(each.key, "ptp", "")}"
  vrf_name     = "default"

  address = "${each.value.sat02_ip}/${split("/", each.value.subnet_cidr)[1]}"
}
