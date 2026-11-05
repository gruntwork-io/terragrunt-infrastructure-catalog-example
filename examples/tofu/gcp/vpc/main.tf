terraform {
  required_version = ">= 1.1"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.0"
    }
  }
}

module "vpc" {
  source = "../../../../modules/gcp/vpc"

  name   = var.name
  region = var.region

  subnets = {
    private = {
      ip_cidr_range = "10.0.1.0/24"
    }
    public = {
      ip_cidr_range = "10.0.101.0/24"
    }
  }
}
