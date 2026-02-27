locals {
  # Split the /24 deterministically into three ranges: loopbacks, SVIs, P2P
  # cidrsubnets(base, newbits_for_loopbacks, newbits_for_svis, newbits_for_ptp)
  base_subnets = cidrsubnets(
    var.fabric_cidr,
    var.subnet_plan.loopback_mask_bits - tonumber(regex(".*\\/(\\d+)", var.fabric_cidr)[0]),
    var.subnet_plan.svi_mask_bits      - tonumber(regex(".*\\/(\\d+)", var.fabric_cidr)[0]),
    var.subnet_plan.ptp_mask_bits      - tonumber(regex(".*\\/(\\d+)", var.fabric_cidr)[0])
  )

  loopback_block = local.base_subnets[0]
  svi_block      = local.base_subnets[1]
  ptp_block      = local.base_subnets[2]

  # Loopback /32s – allocate num_loopbacks per switch (agg01/agg02 get same IP or different, your choice)
  loopbacks_agg01 = {
    for i in range(var.subnet_plan.num_loopbacks) :
    "lo${i + 1}" => {
      ip = cidrhost(local.loopback_block, i) # /32 host IP
    }
  }

  loopbacks_agg02 = {
    for i in range(var.subnet_plan.num_loopbacks) :
    "lo${i + 1}" => {
      ip = cidrhost(local.loopback_block, i) # could offset if you want unique per switch
    }
  }

  # SVI /28s, then first host for gw on each switch (same virtual IP on both if using HSRP/anycast, or different)
  svi_subnets = {
    for i in range(var.subnet_plan.num_svis) :
    "vlan${10 + i}" => cidrsubnet(local.svi_block, 0, i)
  }

  svis_agg01 = {
    for k, cidr in local.svi_subnets :
    k => {
      subnet_cidr = cidr
      ip          = cidrhost(cidr, 1)
    }
  }

  svis_agg02 = {
    for k, cidr in local.svi_subnets :
    k => {
      subnet_cidr = cidr
      ip          = cidrhost(cidr, 2) # could also be 1 if shared vIP
    }
  }

  # P2P /31s, one per link, two IPs per /31 (index 0 and 1)
  ptp_subnets = {
    for i in range(var.subnet_plan.num_ptp_links) :
    "ptp${i + 1}" => cidrsubnet(local.ptp_block, 1, i)
  }

  ptp_links = {
    for name, cidr in local.ptp_subnets :
    name => {
      subnet_cidr = cidr
      agg01_ip    = cidrhost(cidr, 0)
      agg02_ip    = cidrhost(cidr, 1)
    }
  }
}

output "loopbacks_agg01" { value = local.loopbacks_agg01 }
output "loopbacks_agg02" { value = local.loopbacks_agg02 }
output "svis_agg01"      { value = local.svis_agg01 }
output "svis_agg02"      { value = local.svis_agg02 }
output "ptp_links"       { value = local.ptp_links }
