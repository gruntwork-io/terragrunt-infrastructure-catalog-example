# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the network security rule"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group that contains the network security group"
  type        = string
}

variable "network_security_group_name" {
  description = "The name of the network security group to add the rule to"
  type        = string
}

variable "priority" {
  description = "The priority of the rule, from 100 to 4096. Lower numbers are evaluated first."
  type        = number
}

variable "destination_port_range" {
  description = "The destination port or port range the rule applies to (e.g. 443 or 8000-8080)"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "direction" {
  description = "The direction of traffic the rule applies to (Inbound or Outbound)"
  type        = string
  default     = "Inbound"
}

variable "access" {
  description = "Whether the rule allows or denies matching traffic (Allow or Deny)"
  type        = string
  default     = "Allow"
}

variable "protocol" {
  description = "The protocol the rule applies to (Tcp, Udp, Icmp, Esp, Ah or *)"
  type        = string
  default     = "Tcp"
}

variable "source_address_prefix" {
  description = "The source CIDR or service tag the rule applies to (e.g. VirtualNetwork, Internet or 10.0.0.0/16). Defaults to traffic from inside the virtual network only."
  type        = string
  default     = "VirtualNetwork"
}

variable "destination_address_prefix" {
  description = "The destination CIDR or service tag the rule applies to"
  type        = string
  default     = "*"
}
