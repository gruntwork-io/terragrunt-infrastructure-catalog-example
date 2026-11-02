# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the managed identity"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to create the managed identity in"
  type        = string
}

variable "location" {
  description = "The Azure region to create the managed identity in (e.g. eastus)"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "role_assignments" {
  description = "The roles to grant the identity, keyed by a static label. Each entry sets the scope (a resource ID) and the built-in role name (e.g. AcrPull)."
  type = map(object({
    scope                = string
    role_definition_name = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to the managed identity"
  type        = map(string)
  default     = {}
}
