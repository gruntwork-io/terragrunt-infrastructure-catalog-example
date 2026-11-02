# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region to create the resource group in (e.g. eastus)"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "tags" {
  description = "Tags to apply to the resource group"
  type        = map(string)
  default     = {}
}
