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
  raw_yaml = yamldecode(file("${path.root}/common.yaml"))

  # Filter in the 'common_settings' block 
  # so Terraform uses only the common settings (vlans)

  device_data = { 
    for k, v in local.raw_yaml : k => v 
    if k != "common_settings" 
  }

# 2. Flatten: Create a map entry for every VLAN on every device
  device_vlans = merge([
    for device_key, device_val in local.device_data: {
      for vlan_id, vlan_val in local.raw_yaml.common_settings.vlans :
      "${device_key}.${vlan_id}" => {
        device       = device_key
        vlan_id      = try(vlan_id, "enabled") # This is a workaround to handle the case where vlan_id might not be present in the YAML")
        name         = try(vlan_val.name, "DEFAULT")
        fabric_encap = try(vlan_val.fabric_encap, 999)
        #bfd_admin_state = try(local.raw_yaml.common_settings.features.bfd.admin_state, "disabled")
      }
    }
  ]...) # The '...' is important to merge the list of maps into one map

  device_feature = merge([
    for device_key, device_val in local.device_data: {
      for df_id, df_val in local.raw_yaml.common_settings.features :
      "${device_key}.${df_id}" => {
        device       = device_key
        admin_state = try(df_val.admin_state, "disabled")
      }
    }
  ]...)

}

provider "nxos" {
  username = "cisco"
  password = "cisco"
  devices  = concat(local.leafs)
}

resource "nxos_bridge_domain" "vlan-common" {
  for_each = local.device_vlans
  device = each.value.device
  fabric_encap = "vlan-${each.value.fabric_encap}"
  name         = "${each.value.name}"
}

resource "nxos_feature_bfd" "bfd" {
  for_each = local.device_feature
  device = each.value.device
  admin_state = each.value.admin_state
}

##### OUTPUT Module - will be used to return output to Root #####
data "nxos_bridge_domain" "vlans_module" {
  for_each = local.device_vlans
  device = each.value.device
  fabric_encap        = "vlan-${each.value.fabric_encap}"
}

output "vlans_module" {
  value = data.nxos_bridge_domain.vlans_module
}