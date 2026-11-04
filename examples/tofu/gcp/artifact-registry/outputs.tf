output "name" {
  description = "The short name of the repository (e.g. my-repo)"
  value       = module.artifact_registry.name
}

output "id" {
  description = "The full resource path of the repository, in the form projects/<project>/locations/<location>/repositories/<name>"
  value       = module.artifact_registry.id
}

output "registry_uri" {
  description = "The address to push and pull from (e.g. us-east1-docker.pkg.dev/my-project/my-repo)"
  value       = module.artifact_registry.registry_uri
}
