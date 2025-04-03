variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "The name of the DynamoDB table"
  type        = string
  default     = "example-table"
}

variable "hash_key" {
  description = "The hash key of the DynamoDB table"
  type        = string
  default     = "id"
}

variable "hash_key_type" {
  description = "The type of the hash key (S for string, N for number)"
  type        = string
  default     = "S"
}

variable "billing_mode" {
  description = "The billing mode for the DynamoDB table (PAY_PER_REQUEST or PROVISIONED)"
  type        = string
  default     = "PAY_PER_REQUEST"
}
