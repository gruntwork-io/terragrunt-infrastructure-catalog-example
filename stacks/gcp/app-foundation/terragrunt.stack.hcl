locals {
  // `name` starts the service account ID, which allows at most 30 lowercase
  // letters, digits and hyphens, so names longer than 27 characters fail at plan time.
  name     = values.name
  location = values.location
  labels   = try(values.labels, {})
}

unit "bucket" {
  // The `//` marks the repository root. That context lets each generated unit
  // properly use `update_source_with_cas` to find its relative paths within the
  // catalog and materialize them from the CAS.
  source                 = "../../..//units/gcp/storage-bucket"
  update_source_with_cas = true

  path = "bucket"

  values = {
    name     = "${local.name}-data"
    location = local.location
    labels   = local.labels
  }
}

unit "database" {
  source                 = "../../..//units/gcp/firestore-database"
  update_source_with_cas = true

  path = "database"

  values = {
    name     = "${local.name}-db"
    location = local.location

    enable_delete_protection = try(values.enable_delete_protection, true)
  }
}

unit "registry" {
  source                 = "../../..//units/gcp/artifact-registry"
  update_source_with_cas = true

  path = "registry"

  values = {
    name     = "${local.name}-images"
    location = local.location
    labels   = local.labels
  }
}

// The identity an app runs as. It can pull images from the registry, read
// objects in the bucket and read/write documents in the database, and nothing else.
unit "identity" {
  source                 = "../../..//units/gcp/service-account"
  update_source_with_cas = true

  path = "identity"

  values = {
    name         = "${local.name}-sa"
    display_name = "${local.name} app"
  }

  autoinclude {
    dependency "bucket" {
      config_path = unit.bucket.path

      mock_outputs = {
        name = "mock-bucket"
      }
    }

    dependency "database" {
      config_path = unit.database.path

      mock_outputs = {
        id = "projects/mock-project/databases/mock-db"
      }
    }

    dependency "registry" {
      config_path = unit.registry.path

      mock_outputs = {
        name     = "mock-registry"
        location = "us-east1"
      }
    }

    inputs = {
      repository_roles = {
        artifact_reader = {
          location   = dependency.registry.outputs.location
          repository = dependency.registry.outputs.name
          role       = "roles/artifactregistry.reader"
        }
      }

      bucket_roles = {
        object_viewer = {
          bucket = dependency.bucket.outputs.name
          role   = "roles/storage.objectViewer"
        }
      }

      // Firestore has no per-database IAM, so the role is granted on the project
      // and the condition narrows it to this database.
      project_roles = {
        datastore_user = {
          role = "roles/datastore.user"

          condition = {
            title      = "${local.name}-db only"
            expression = "resource.name == \"${dependency.database.outputs.id}\""
          }
        }
      }
    }
  }
}

unit "alerts" {
  enabled = try(values.enable_alerts, false)

  source                 = "../../..//units/gcp/monitoring-alerts"
  update_source_with_cas = true

  path = "alerts"

  values = {
    name            = local.name
    email_addresses = try(values.alert_email_addresses, [])
    labels          = local.labels

    metric_alerts = {
      errors = {
        metric_type = "storage.googleapis.com/api/request_count"
        filter      = "metric.label.response_code != \"OK\""
        comparison  = "COMPARISON_GT"
        threshold   = 1
        description = "Requests to the bucket for ${local.name} are failing at over one per second."
      }

      egress = {
        metric_type = "storage.googleapis.com/network/sent_bytes_count"
        comparison  = "COMPARISON_GT"
        threshold   = 10485760
        description = "The bucket for ${local.name} is sending over 10 MiB/s."
      }
    }
  }

  autoinclude {
    dependency "bucket" {
      config_path = unit.bucket.path

      mock_outputs = {
        name = "mock-bucket"
      }
    }

    inputs = {
      resource_filter = "resource.type = \"gcs_bucket\" AND resource.label.bucket_name = \"${dependency.bucket.outputs.name}\""
    }
  }
}
