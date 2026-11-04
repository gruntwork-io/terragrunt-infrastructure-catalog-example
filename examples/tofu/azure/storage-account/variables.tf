# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the storage account. Must be 3-24 lowercase letters and digits, and unique across all of Azure. The resource group is named after it."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "name must be 3-24 lowercase letters and digits."
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "location" {
  description = "The Azure region to deploy into"
  type        = string
  default     = "eastus"
}
