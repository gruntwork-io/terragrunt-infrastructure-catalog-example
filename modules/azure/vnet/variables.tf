# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the virtual network"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to create the virtual network in"
  type        = string
}

variable "location" {
  description = "The Azure region to create the virtual network in (e.g. eastus)"
  type        = string
}

variable "address_space" {
  description = "The address space of the virtual network (e.g. [\"10.0.0.0/16\"])"
  type        = list(string)
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "subnets" {
  description = "The subnets to create in the virtual network, keyed by subnet name"
  type = map(object({
    address_prefixes = list(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to the virtual network"
  type        = map(string)
  default     = {}
}
