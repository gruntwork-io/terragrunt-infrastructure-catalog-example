# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SERVICE ACCOUNT
# ---------------------------------------------------------------------------------------------------------------------

resource "google_service_account" "account" {
  account_id   = var.name
  display_name = var.display_name
}

# ---------------------------------------------------------------------------------------------------------------------
# GRANT THE SERVICE ACCOUNT ROLES ON OTHER RESOURCES
# Each map's keys are known at plan time, so the resources can come from units that don't exist yet.
# ---------------------------------------------------------------------------------------------------------------------

resource "google_project_iam_member" "project" {
  for_each = var.project_roles

  project = google_service_account.account.project
  role    = each.value.role
  member  = google_service_account.account.member

  dynamic "condition" {
    for_each = each.value.condition == null ? [] : [each.value.condition]

    content {
      title      = condition.value.title
      expression = condition.value.expression
    }
  }
}

resource "google_storage_bucket_iam_member" "bucket" {
  for_each = var.bucket_roles

  bucket = each.value.bucket
  role   = each.value.role
  member = google_service_account.account.member
}

resource "google_artifact_registry_repository_iam_member" "repository" {
  for_each = var.repository_roles

  location   = each.value.location
  repository = each.value.repository
  role       = each.value.role
  member     = google_service_account.account.member
}
