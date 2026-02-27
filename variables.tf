# variable "fabric_cidr" {
#   description = "Top-level /24 used to derive all Nexus IPs"
#   type        = string
# }

variable "switch_pair_name" {
  description = "Logical name for this pair"
  type        = string
}

# variable "nxos_username" { type = string }
# variable "nxos_password" { type = string }

# variable "switches" {
#   description = "Two switches in the pair"
#   type = object({
#     sat01_url = string
#     sat02_url = string
#   })
# }

# # Describe what you want carved from the /24 for this pair
# variable "subnet_plan" {
#   description = "How the /24 should be split for this pair"
#   type = object({
#     loopback_mask_bits  = number # e.g. 32 => /32s from /24
#     svi_mask_bits       = number # e.g. 28 => /28s for SVIs
#     ptp_mask_bits       = number # e.g. 31 => /31s for P2P links
#     num_loopbacks       = number
#     num_svis            = number
#     num_ptp_links       = number
#   })
# }
