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

module "ecr_repository" {
  source = "../../../modules/ecr-repository"

  name                 = var.name
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete
  encryption_type      = var.encryption_type
  scan_on_push         = var.scan_on_push
}
