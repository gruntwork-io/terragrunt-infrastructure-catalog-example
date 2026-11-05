# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the firewall rule. Must be unique across the project."
  type        = string
}

variable "network" {
  description = "The ID or URI of the VPC network to add the rule to"
  type        = string
}

variable "priority" {
  description = "The priority of the rule, from 0 to 65535. Lower numbers are evaluated first."
  type        = number
}

variable "ports" {
  description = "The destination ports or port ranges the rule applies to (e.g. [\"443\"] or [\"8000-8080\"])"
  type        = list(string)
}

variable "source_ranges" {
  description = "The source CIDR ranges the rule applies to (e.g. [\"0.0.0.0/0\"] for the internet or [\"10.0.0.0/8\"])"
  type        = list(string)
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "direction" {
  description = "The direction of traffic the rule applies to (INGRESS or EGRESS)"
  type        = string
  default     = "INGRESS"
}

variable "action" {
  description = "Whether the rule allows or denies matching traffic (allow or deny)"
  type        = string
  default     = "allow"

  validation {
    condition     = contains(["allow", "deny"], var.action)
    error_message = "action must be allow or deny."
  }
}

variable "protocol" {
  description = "The protocol the rule applies to (tcp, udp, icmp, esp, ah, sctp or all)"
  type        = string
  default     = "tcp"
}

variable "target_tags" {
  description = "The network tags of the instances the rule applies to. Leave empty to apply the rule to every instance in the network."
  type        = list(string)
  default     = []
}
