variable "module_device_data" {
  type = map(object({
    fabric_encap = string
    name   = string
  }))
}

variable "common_vlan_data" {}