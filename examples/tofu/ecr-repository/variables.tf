variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "The name of the ECR repository"
  type        = string
  default     = "example-repository"
}

variable "image_tag_mutability" {
  description = "The image tag mutability of the ECR repository"
  type        = string
  default     = "MUTABLE"
}

variable "force_delete" {
  description = "Allow the ECR repository to be deleted even if it contains images"
  type        = bool
  default     = false
}

variable "encryption_type" {
  description = "The encryption type of the ECR repository"
  type        = string
  default     = "AES256"
}

variable "scan_on_push" {
  description = "Scan the repository for vulnerabilities"
  type        = bool
  default     = true
}
