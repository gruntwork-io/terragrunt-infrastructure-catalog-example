# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the bucket. Must be 3-63 lowercase letters, digits, hyphens and underscores, starting and ending with a letter or digit, and unique across all of GCP."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9_-]{1,61}[a-z0-9]$", var.name))
    error_message = "name must be 3-63 lowercase letters, digits, hyphens and underscores, starting and ending with a letter or digit."
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "location" {
  description = "The GCP location to create the bucket in"
  type        = string
  default     = "us-east1"
}
