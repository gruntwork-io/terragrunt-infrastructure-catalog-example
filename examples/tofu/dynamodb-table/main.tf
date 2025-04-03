terraform {
  required_version = ">= 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "dynamodb_table" {
  source = "../../../modules/dynamodb-table"

  name          = var.name
  hash_key      = var.hash_key
  hash_key_type = var.hash_key_type
  billing_mode  = var.billing_mode
}
