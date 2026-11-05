resource "google_firestore_database" "database" {
  name        = var.name
  location_id = var.location
  type        = "FIRESTORE_NATIVE"

  delete_protection_state = var.enable_delete_protection ? "DELETE_PROTECTION_ENABLED" : "DELETE_PROTECTION_DISABLED"

  # The provider defaults to ABANDON, which removes the database from state on destroy and leaves it running in GCP.
  deletion_policy = "DELETE"
}
