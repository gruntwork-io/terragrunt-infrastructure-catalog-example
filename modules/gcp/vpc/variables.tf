# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the VPC network. Each subnet is named after it."
  type        = string
}

variable "region" {
  description = "The GCP region to create the subnets in (e.g. us-east1)"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "subnets" {
  description = "The subnets to create in the network, keyed by a short name. Each subnet is named <name>-<key>."
  type = map(object({
    ip_cidr_range = string
  }))
  default = {}
}
