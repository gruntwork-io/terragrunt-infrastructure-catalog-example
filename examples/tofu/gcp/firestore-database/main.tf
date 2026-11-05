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
}
