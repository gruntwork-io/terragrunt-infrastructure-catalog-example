# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the table. Must be 3-63 letters and digits, starting with a letter."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9]{2,62}$", var.name))
    error_message = "name must be 3-63 letters and digits, starting with a letter."
  }
}

variable "storage_account_id" {
  description = "The ID of the storage account to create the table in"
  type        = string
}
