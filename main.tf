terraform {
  required_providers {
    nxos = {
      source  = "CiscoDevNet/nxos"
      #version = "~> 0.8.0-beta7" # example, pin what you actually use
    }
  }
}

locals {
  cfg = yamldecode(file("./fabric.yaml"))
}


# locals {
#   devices = [
#     {
#       name    = "SAT-01"
#       url     = "https://192.168.1.166"
#       managed = true   # Actively managed
#     },
#     {
#       name    = "SAT-02"
#       url     = "https://192.168.1.144"
#       managed = true  # Temporarily freeze with false to halt use
#     },

#   ]
# }

provider "nxos" {
  username = "cisco"
  password = "cisco"
  devices  = local.devices
}

resource "nxos_system" "hostname" {
  for_each     = local.cfg.devices
  name         = each.value.name
}

# resource "nxos_system" "hostname" {
#   for_each    = {for d in local.devices : d.name => d}
#   device      = each.key
#   name        = "${each.value.name}"
 
# }

# resource "nxos_vrf" "VRF1" {
#   for_each    = toset([for device in local.devices : device.name])
#   device      = each.key
#   name        = "VRF1"
#   description = "My VRF1 Description"
# }