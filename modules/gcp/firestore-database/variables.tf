# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The short name of the database. Must be 4-63 lowercase letters, digits and hyphens, starting with a letter and ending with a letter or digit."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,61}[a-z0-9]$", var.name))
    error_message = "name must be 4-63 lowercase letters, digits and hyphens, starting with a letter and ending with a letter or digit."
  }
}

variable "location" {
  description = "The location of the database: a region (e.g. us-east1) or a multi-region (e.g. nam5)"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "enable_delete_protection" {
  description = "If set to true, GCP refuses to delete the database, so destroying it fails until this is set back to false."
  type        = bool
  default     = false
}
