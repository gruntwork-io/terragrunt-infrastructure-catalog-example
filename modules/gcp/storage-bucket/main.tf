resource "google_storage_bucket" "bucket" {
  name          = var.name
  location      = var.location
  storage_class = var.storage_class
  force_destroy = var.force_destroy

  # Grant access with IAM on the whole bucket, never with per-object ACLs.
  uniform_bucket_level_access = true

  # Keep every object private.
  public_access_prevention = var.block_public_access ? "enforced" : "inherited"

  versioning {
    enabled = var.enable_versioning
  }

  labels = var.labels
}
