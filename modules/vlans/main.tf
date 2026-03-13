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
#   #raw_yaml = yamldecode(file("./.yaml"))

#   # Filter out the 'common_settings' block so Terraform doesn't 
#   # try to treat it like a real switch.
# ###### Extract the commn.yaml data into a separate local variable for easier reference in the module
#   #raw_common_yaml = yamldecode(file("./common.yaml")) 

# # 1. Extract the common settings into a single object
#   #common = local.raw_common_yaml["common_settings"]

# #     common_data = { 
# #     for k, v in var.common_vlan_data : k => v 
# #     if k == "common_settings" 
# #   }

# # 2. Flatten: Create a map entry for every VLAN on every device
#   device_vlans = merge([
#     for device_key, device_val in var.module_device_data: {
#       for vlan_id, vlan_val in var.common_vlan_data.vlans :
#       "${device_key}.${vlan_id}" => {
#         device       = device_key
#         vlan_id      = vlan_id
#         name         = vlan_val.name
#         fabric_encap = vlan_val.fabric_encap
#       }
#     }
#   ]...) # The '...' is important to merge the list of maps into one map
vlans = var.raw_vlans_yaml

}
provider "nxos" {
  username = "cisco"
  password = "cisco"
  devices  = concat(local.leafs)
}
resource "nxos_bridge_domain" "vlan-vlan_mod" {
  for_each    = toset([for leaf in local.leafs : leaf.name])
  device      = each.key
  fabric_encap = "vlan-${each.value.fabric_encap}"
  name         = "${each.value.name}"
}


STUCK STUCK STUCK STUCK STUCK STUCK STUCK STUCK STUCK STUCK STUCK STUCK