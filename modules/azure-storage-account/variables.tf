# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the storage account. Must be 3-24 lowercase letters and digits, and unique across all of Azure."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to create the storage account in"
  type        = string
}

variable "location" {
  description = "The Azure region to create the storage account in (e.g. eastus)"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "container_names" {
  description = "The names of the private blob containers to create in the storage account"
  type        = list(string)
  default     = []
}

variable "account_tier" {
  description = "The performance tier of the storage account (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "The replication type of the storage account (e.g. LRS, ZRS, GRS)"
  type        = string
  default     = "LRS"
}

variable "block_public_access" {
  description = "If set to true, no container in the storage account can be made public."
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "If set to true, enable blob versioning to protect against accidental or malicious deletion/modification of blobs."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the storage account"
  type        = map(string)
  default     = {}
}
