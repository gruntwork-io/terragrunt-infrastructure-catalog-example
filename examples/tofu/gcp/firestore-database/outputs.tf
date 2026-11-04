output "name" {
  description = "The short name of the database (e.g. my-db)"
  value       = module.firestore_database.name
}

output "id" {
  description = "The full resource path of the database, in the form projects/<project>/databases/<name>"
  value       = module.firestore_database.id
}
