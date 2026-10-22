# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the container registry. Must be 5-50 letters and digits, and unique across all of Azure."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to create the container registry in"
  type        = string
}

variable "location" {
  description = "The Azure region to create the container registry in (e.g. eastus)"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "sku" {
  description = "The SKU of the container registry (Basic, Standard or Premium)"
  type        = string
  default     = "Basic"
}

variable "admin_enabled" {
  description = "If set to true, enable the admin user. Prefer granting the AcrPull/AcrPush roles to identities instead."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the container registry"
  type        = map(string)
  default     = {}
}
