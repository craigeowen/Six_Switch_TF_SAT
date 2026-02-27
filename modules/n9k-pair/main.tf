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