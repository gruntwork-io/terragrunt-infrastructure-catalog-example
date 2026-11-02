# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the storage account. Must be 3-24 lowercase letters and digits, and unique across all of Azure. The resource group is named after it."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "location" {
  description = "The Azure region to deploy into"
  type        = string
  default     = "eastus"
}
