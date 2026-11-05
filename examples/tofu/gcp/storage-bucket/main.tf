terraform {
  required_version = ">= 1.1"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.0"
    }
  }
}

module "storage_bucket" {
  source = "../../../../modules/gcp/storage-bucket"

  name     = var.name
  location = var.location
}
