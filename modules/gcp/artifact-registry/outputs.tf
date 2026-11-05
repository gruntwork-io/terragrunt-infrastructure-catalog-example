output "name" {
  description = "The short name of the repository (e.g. my-repo)"
  value       = google_artifact_registry_repository.repository.repository_id
}

output "id" {
  description = "The full resource path of the repository, in the form projects/<project>/locations/<location>/repositories/<name>"
  value       = google_artifact_registry_repository.repository.id
}

output "location" {
  description = "The location of the repository"
  value       = google_artifact_registry_repository.repository.location
}

output "registry_uri" {
  description = "The address to push and pull from (e.g. us-east1-docker.pkg.dev/my-project/my-repo)"
  value       = google_artifact_registry_repository.repository.registry_uri
}
