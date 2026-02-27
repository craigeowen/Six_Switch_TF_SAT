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


# Configure the Cisco NX-OS provider
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