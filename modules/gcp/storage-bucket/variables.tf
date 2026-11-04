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

variable "location" {
  description = "The location of the bucket: a region (e.g. us-east1), a dual-region or a multi-region (e.g. US)"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "storage_class" {
  description = "The storage class of the bucket (STANDARD, NEARLINE, COLDLINE or ARCHIVE)"
  type        = string
  default     = "STANDARD"
}

variable "block_public_access" {
  description = "If set to true, no object in the bucket can be made public."
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "If set to true, enable object versioning to protect against accidental or malicious deletion/modification of objects."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "If set to true, destroying the bucket also deletes every object in it. Otherwise, destroying a bucket that still has objects fails."
  type        = bool
  default     = false
}

variable "labels" {
  description = "Labels to apply to the bucket"
  type        = map(string)
  default     = {}
}
