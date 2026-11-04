# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The short name of the repository. Must be 1-63 lowercase letters, digits and hyphens, starting with a letter and ending with a letter or digit, and unique in its location."
  type        = string

  validation {
    condition     = can(regex("^[a-z]([a-z0-9-]{0,61}[a-z0-9])?$", var.name))
    error_message = "name must be 1-63 lowercase letters, digits and hyphens, starting with a letter and ending with a letter or digit."
  }
}

variable "location" {
  description = "The location to create the repository in: a region (e.g. us-east1) or a multi-region (e.g. us)"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "format" {
  description = "The format of the packages the repository stores (e.g. DOCKER, NPM, PYTHON or GO)"
  type        = string
  default     = "DOCKER"
}

variable "labels" {
  description = "Labels to apply to the repository"
  type        = map(string)
  default     = {}
}
