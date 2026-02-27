variable "fabric_cidr" {
  description = "Top-level /24"
  type        = string
}

variable "switch_pair_id" {
  description = "Name/id of the switch pair"
  type        = string
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
