terraform {
  required_providers {
    nxos = {
      source  = "CiscoDevNet/nxos"
      version = "~> 0.5.10" # example, pin what you actually use
    }
  }
}

# Configure the Cisco NX-OS provider