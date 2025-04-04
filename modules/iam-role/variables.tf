variable "name" {
  description = "The name of the IAM role"
  type        = string
}

variable "assume_role_policy" {
  description = "The assume role policy for the IAM role"
  type        = string
}

variable "policy" {
  description = "The policy for the IAM role"
  type        = string
}

