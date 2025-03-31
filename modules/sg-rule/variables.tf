# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "from_port" {
  type        = number
  description = "The start port number of the range"
}

variable "to_port" {
  type        = number
  description = "The end port number of the range"
}

variable "security_group_id" {
  type        = string
  description = "The ID of the security group to apply the rule to"
}



# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "type" {
  type        = string
  description = "The type of security group rule to create"
  default     = "ingress"
}

variable "protocol" {
  type        = string
  description = "The protocol to use for the security group rule"
  default     = "tcp"
}

variable "source_security_group_id" {
  type        = string
  description = "The ID of the source security group to apply the rule to"
  default     = null
}

variable "cidr_blocks" {
  type        = list(string)
  description = "The CIDR blocks to apply the rule to"
  default     = null
}


