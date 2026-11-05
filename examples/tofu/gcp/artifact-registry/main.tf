terraform {
  required_version = ">= 1.1"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.0"
    }
  }
}

module "artifact_registry" {
  source = "../../../../modules/gcp/artifact-registry"

  name     = var.name
  location = var.location
}
