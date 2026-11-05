# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The account ID of the service account, which starts its email address. Must be 6-30 lowercase letters, digits and hyphens, starting with a letter and ending with a letter or digit."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.name))
    error_message = "name must be 6-30 lowercase letters, digits and hyphens, starting with a letter and ending with a letter or digit."
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "display_name" {
  description = "The display name of the service account"
  type        = string
  default     = null
}

variable "project_roles" {
  description = "The roles to grant the service account on the project, keyed by a static label. A condition narrows the grant, e.g. to one Firestore database."
  type = map(object({
    role = string
    condition = optional(object({
      title      = string
      expression = string
    }))
  }))
  default = {}
}

variable "bucket_roles" {
  description = "The roles to grant the service account on Cloud Storage buckets, keyed by a static label (e.g. roles/storage.objectViewer)"
  type = map(object({
    bucket = string
    role   = string
  }))
  default = {}
}

variable "repository_roles" {
  description = "The roles to grant the service account on Artifact Registry repositories, keyed by a static label (e.g. roles/artifactregistry.reader)"
  type = map(object({
    location   = string
    repository = string
    role       = string
  }))
  default = {}
}
