# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The short name of the repository. Must be 1-63 lowercase letters, digits and hyphens, starting with a letter and ending with a letter or digit."
  type        = string

  validation {
    condition     = can(regex("^[a-z]([a-z0-9-]{0,61}[a-z0-9])?$", var.name))
    error_message = "name must be 1-63 lowercase letters, digits and hyphens, starting with a letter and ending with a letter or digit."
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "location" {
  description = "The GCP location to create the repository in"
  type        = string
  default     = "us-east1"
}
