# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the network security group"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to create the network security group in"
  type        = string
}

variable "location" {
  description = "The Azure region to create the network security group in (e.g. eastus)"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "subnet_ids" {
  description = "The IDs of the subnets to attach the network security group to, keyed by a static label such as the subnet name"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to the network security group"
  type        = map(string)
  default     = {}
}
