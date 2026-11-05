locals {
  // Bucket names are unique across all of GCP. Set `TG_GCP_NAME_PREFIX` to
  // something unique to your organization, using at most 23 lowercase letters,
  // digits and hyphens, starting with a letter.
  name = "${get_env("TG_GCP_NAME_PREFIX", "tgcatalog")}-app"
}

stack "app" {
  // The `//` marks the repository root. That context lets each generated unit
  // properly use `update_source_with_cas` to find its relative paths within the
  // catalog and materialize them from the CAS.
  source = "${get_repo_root()}//stacks/gcp/app-foundation"

  path = "app"

  values = {
    name     = local.name
    location = "us-east1"

    enable_alerts = true
  }
}
