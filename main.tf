terraform {
  required_providers {
    nxos = {
      source  = "CiscoDevNet/nxos"
      #version = "~> 0.8.0-beta7" # example, pin what you actually use
    }
  }
}

locals {
  leafs = [
    {
      name = "twe-sat01"
      url  = "https://192.168.1.166"
      number = 1
    },
    {
      name = "twe-sat02"
      url  = "https://192.168.1.144"
      number = 2
    },
  ]
  raw_yaml = yamldecode(file("./base.yaml"))

  # Filter out the 'common_settings' block so Terraform doesn't 
  # try to treat it like a real switch.
  device_data = { 
    for k, v in local.raw_yaml : k => v 
    if k != "common_settings" 
  }

# 1. Extract the common settings into a single object
  common = local.raw_yaml["common_settings"]

    common_data = { 
    for k, v in local.raw_yaml : k => v 
    if k == "common_settings" 
  }

# 2. Flatten: Create a map entry for every VLAN on every device
  device_vlans = merge([
    for device_key, device_val in local.device_data: {
      for vlan_id, vlan_val in local.raw_yaml.common_settings.vlans :
      "${device_key}.${vlan_id}" => {
        device       = device_key
        vlan_id      = vlan_id
        name         = vlan_val.name
        fabric_encap = vlan_val.fabric_encap
      }
    }
  ]...) # The '...' is important to merge the list of maps into one map

###### Extract the commn.yaml data into a separate local variable for easier reference in the module
  raw_vlans_yaml = yamldecode(file("./vlans.yaml")) 


}




# Parses a YAML file into a Terraform-compatible map or object structure.
  # 'file' reads the raw text from the disk.
  # 'yamldecode' converts that text into data (lists, maps, strings).
# locals {
#   device_data = yamldecode(file("./base.yaml"))
# }



provider "nxos" {
  username = "cisco"
  password = "cisco"
  devices  = concat(local.leafs)
}


resource "nxos_system" "hostname" {
  for_each = local.device_data
  device = each.key
  name   = each.value.name
}

resource "nxos_vrf" "VRF2" {
  for_each = local.device_data
  device = each.key
  name        = each.value.vrf2_name
  description = each.value.vrf2_description
}

resource "nxos_bridge_domain" "vlan-common" {
  for_each = local.device_vlans
  device = each.value.device
  fabric_encap = "vlan-${each.value.fabric_encap}"
  name         = "${each.value.name}"
}

resource "nxos_save_config" "save-config" {
  for_each = local.device_data
  device = each.key
}



##### Configure  VLANs #####
module "config-common-vlans" {
  source = "./modules/vlans"

}

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