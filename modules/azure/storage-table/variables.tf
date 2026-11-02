# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the table. Must be 3-63 letters and digits, starting with a letter."
  type        = string
}

variable "storage_account_id" {
  description = "The ID of the storage account to create the table in"
  type        = string
}
