# The GCP examples include this file instead of examples/terragrunt/root.hcl,
# because `find_in_parent_folders` returns the closest match.

locals {
  # Both the provider and the backend need the project to deploy into.
  # After `gcloud config set project`, set it with:
  # export GOOGLE_CLOUD_PROJECT="$(gcloud config get-value project)"
  project_id = get_env("GOOGLE_CLOUD_PROJECT")
}

# Generate a GCP provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "google" {
  project = "${local.project_id}"
}
EOF
}

# Configure remote state
remote_state {
  backend = "gcs"
  config = {
    # Set `TG_GCP_STATE_BUCKET` to keep the state in another bucket.
    bucket = get_env("TG_GCP_STATE_BUCKET", "${local.project_id}-tg-catalog-tfstate")
    prefix = path_relative_to_include()

    # Terragrunt creates the bucket with these settings when it doesn't exist yet.
    project                   = local.project_id
    location                  = "us-east1"
    enable_bucket_policy_only = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
