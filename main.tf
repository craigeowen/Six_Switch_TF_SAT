terraform {
  required_providers {
    nxos = {
      source  = "CiscoDevNet/nxos"
      version = "~> 0.7.0" # example, pin what you actually use
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

  # 3. Flatten: Create a map entry for every VRF on every device
  device_vrfs = merge([
    for device_key, device_val in local.device_data: {
      for vrf_id, vrf_val in local.raw_yaml.common_settings.vrfs :
      "${device_key}.${vrf_id}" => {
        device       = device_key
        name         = vrf_val.name
        description  = vrf_val.description
      }
    }
  ]...) # The '...' is important to merge the list of maps into one map

###### Extract the commn.yaml data into a separate local variable for easier reference in the module
  #raw_vlans_yaml = yamldecode(file("./vlans.yaml")) 


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

# Configures the system-level hostname for NX-OS devices
resource "nxos_system" "hostname" {
  for_each = local.device_data
  # Iterates over a collection of devices defined in local.cfg.devices
  # This allows you to manage multiple switches from a single resource block
  device = each.key
  name   = each.value.name
  # Sets the hostname ('name') based on the 'name' attribute of the current device in the loop
}
##### Each block is composed of
##### A Resource Block
##### A data block
##### An output block whcih hold theb output

##### VRF Config

resource "nxos_vrf" "vrf" {
  for_each = local.device_vrfs
  device = each.value.device
  name        = "${each.value.name}"
  description = "${each.value.description}"
}

data "nxos_vrf" "vrf" {
  for_each = local.device_vrfs
  device = each.value.device
  name        = "${each.value.name}"
}

output "vrfs" {
  value = data.nxos_vrf.vrf
} 

##### End of VRF Config

### Vlan config

resource "nxos_bridge_domain" "vlan-common" {
  for_each = local.device_vlans
  device = each.value.device
  fabric_encap = "vlan-${each.value.fabric_encap}"
  name         = "${each.value.name}"
}

data "nxos_bridge_domain" "vlans" {
  for_each = local.device_vlans
  device = each.value.device
  fabric_encap        = "vlan-${each.value.fabric_encap}"
}

output "vlans" {
  value = data.nxos_bridge_domain.vlans
}

##### End of VLAN Config 

##### This is usewd for returned OUTPUT from Modules #####
output "vlans_module" {
  value = module.config-common-vlans.vlans_module
}

output "Eth_Int_module" {
  value = module.config-Eth-Ints.l2_eth_interface
}

##### SAVE RUNNING CONFIG TO STARTUP CONFIG #####

resource "nxos_save_config" "save-config" {
  for_each = local.device_data
  device = each.key
}




##### Configure  modules #####

### Vlans
module "config-common-vlans" {
  source = "./modules/vlans"
  #common_vlan = local.device_vlans
}

### Eth Int
module "config-Eth-Ints" {
  source = "./modules/Eth_Int"
}



####################################################

