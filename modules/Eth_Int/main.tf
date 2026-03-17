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
  raw_yaml = yamldecode(file("${path.root}/Eth_Int.yaml"))

  # Filter in the 'common_settings' block 
  # so Terraform uses only the common settings (vlans)

  device_data = { 
    for k, v in local.raw_yaml : k => v 
    if k != "common_settings" 
  }

# 2. Flatten: Create a map entry for every VLAN on every device
  device_config = merge([
    for device_key, device_val in local.device_data: {
      for dc_id, dc_val in local.raw_yaml.common_settings.l2_eth_interface :
      "${device_key}.${dc_id}" => {
        device       = device_key
        id           = dc_id
        interface_id = dc_val.interface_id
        admin_state  = dc_val.admin_state
        mode         = dc_val.mode
        trunk_vlans  = dc_val.trunk_vlans
        description  = dc_val.description
        layer        = dc_val.layer
      }
    }
  ]...) # The '...' is important to merge the list of maps into one map


}

provider "nxos" {
  username = "cisco"
  password = "cisco"
  devices  = concat(local.leafs)
}

##### Layer 2 Eth Int #####

resource "nxos_physical_interface" "l2_eth_interface" {
  for_each              = {for k, v in local.device_config : k => v}
  interface_id          = "${each.value.interface_id}"
  admin_state           = lookup(each.value, "admin_state", null)
  mode                  = lookup(each.value, "mode", null)
  trunk_vlans           = lookup(each.value, "trunk_vlans", null)
  description           = lookup(each.value, "description", null)
  layer                 = lookup(each.value, "layer", null)
}


##### OUTPUT Module - will be used to return output to Root #####
data "nxos_physical_interface" "l2_eth_interface" {
  for_each = local.device_config
  device = each.value.device
  interface_id          = "${each.value.interface_id}"
}

output "l2_eth_interface" {
  value = data.nxos_physical_interface.l2_eth_interface
}

