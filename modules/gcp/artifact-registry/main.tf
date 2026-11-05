resource "google_artifact_registry_repository" "repository" {
  repository_id = var.name
  location      = var.location
  format        = var.format
  labels        = var.labels
}
