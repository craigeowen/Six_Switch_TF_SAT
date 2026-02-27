variable "pair_name" {
  description = "Logical name of this Nexus pair"
  type        = string
}

variable "loopbacks_sat01" {
  type = map(object({
    ip = string
  }))
}

variable "loopbacks_sat02" {
  type = map(object({
    ip = string
  }))
}

variable "svis_sat01" {
  type = map(object({
    subnet_cidr = string
    ip          = string
  }))
}

variable "svis_sat02" {
  type = map(object({
    subnet_cidr = string
    ip          = string
  }))
}

variable "ptp_links" {
  type = map(object({
    subnet_cidr = string
    sat01_ip    = string
    sat02_ip    = string
  }))
}
