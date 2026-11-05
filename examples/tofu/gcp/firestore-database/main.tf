terraform {
  required_version = ">= 1.1"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.0"
    }
  }
}

module "firestore_database" {
  source = "../../../../modules/gcp/firestore-database"

  name     = var.name
  location = var.location

  # Do NOT copy this into product code. We only set this param to false here so that the automated tests can clean up.
  enable_delete_protection = false
}
