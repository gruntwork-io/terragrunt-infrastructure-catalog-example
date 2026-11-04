output "name" {
  description = "The short name of the database (e.g. my-db)"
  value       = google_firestore_database.database.name
}

output "id" {
  description = "The full resource path of the database, in the form projects/<project>/databases/<name>"
  value       = google_firestore_database.database.id
}
