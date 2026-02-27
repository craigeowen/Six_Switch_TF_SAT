terraform {
  required_providers {
    nxos = {
      source  = "CiscoDevNet/nxos"
      version = "~> 0.5.10" # example, pin what you actually use
    }
  }
}

locals {
  cfg = yamldecode(file("${path.module}/fabric.yaml"))
}

variable "fabric_cidr"      { type = string }
variable "switch_pair_name" { type = string }
variable "nxos_username"    { type = string }
variable "nxos_password"    { type = string }

variable "switches" {
  type = object({
    agg01_url = string
    agg02_url = string
  })
}

variable "subnet_plan" {
  type = object({
    loopback_mask_bits = number
    svi_mask_bits      = number
    ptp_mask_bits      = number
    num_loopbacks      = number
    num_svis           = number
    num_ptp_links      = number
  })
}

# Assign YAML into variables via defaults or a separate locals-to-vars pattern:
# simplest is to skip variables entirely and feed modules/providers from local.cfg


provider "nxos" {
  alias    = "sat01"
  username = var.nxos_username
  password = var.nxos_password
  url      = var.switches.sat01_url
}

provider "nxos" {
  alias    = "sat02"
  username = var.nxos_username
  password = var.nxos_password
  url      = var.switches.sat02_url
}

module "ip_plan" {
  source = "./modules/ip-plan"

  fabric_cidr    = var.fabric_cidr
  subnet_plan    = var.subnet_plan
  switch_pair_id = var.switch_pair_name
}

module "n9k_pair" {
  source = "./modules/n9k-pair"

#   providers = {
#     nxos.sat01 = nxos.sat01
#     nxos.sat02 = nxos.sat02
#   }

  pair_name = var.switch_pair_name

  # consume the derived IPs/subnets
  loopbacks_sat01 = module.ip_plan.loopbacks_sat01
  loopbacks_sat02 = module.ip_plan.loopbacks_sat02

  svis_sat01 = module.ip_plan.svis_sat01
  svis_sat02 = module.ip_plan.svis_sat02

  ptp_links = module.ip_plan.ptp_links
}
