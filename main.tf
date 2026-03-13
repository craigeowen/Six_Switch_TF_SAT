terraform {
  required_providers {
    nxos = {
      source  = "CiscoDevNet/nxos"
      #version = "~> 0.8.0-beta7" # example, pin what you actually use
    }
  }
}

provider "nxos" {
  alias    = "LEAF-1"
  username = "cisco"
  password = "cisco"
  url      = "https://192.168.1.166"
}

provider "nxos" {
  alias    = "LEAF-2"
  username = "cisco"
  password = "cisco"
  url      = "https://192.168.1.144"
}

resource "nxos_vrf" "LEAF-1-VRF1" {
  provider    = nxos.LEAF-1
  name        = "VRF1"
  description = "My VRF1 Description"
}

resource "nxos_vrf" "LEAF-2-VRF1" {
  provider    = nxos.LEAF-2
  name        = "VRF1"
  description = "My VRF1 Description"
}

# Parses a YAML file into a Terraform-compatible map or object structure.
  # 'file' reads the raw text from the disk.
  # 'yamldecode' converts that text into data (lists, maps, strings).
# locals {
#   cfg = yamldecode(file("./fabric.yaml"))
# }


# Configures the system-level hostname for NX-OS devices

#resource "nxos_system" "hostname" 

  #for_each     = local.cfg.devices
  # Iterates over a collection of devices defined in local.cfg.devices
  # This allows you to manage multiple switches from a single resource block

  #name         = each.value.name
  # Sets the hostname ('name') based on the 'name' attribute of the current device in the loop



# resource "nxos_system" "hostname" {
#   for_each     = local.cfg.devices
#   name         = each.value.name
# }
####################################################
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