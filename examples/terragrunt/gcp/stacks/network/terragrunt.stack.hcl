locals {
  // Set `TG_GCP_NAME_PREFIX` to keep the network and firewall rules this example
  // creates from colliding with existing ones in your project.
  name = "${get_env("TG_GCP_NAME_PREFIX", "tgcatalog")}-network"
}

stack "network" {
  // The `//` marks the repository root. That context lets each generated unit
  // properly use `update_source_with_cas` to find its relative paths within the
  // catalog and materialize them from the CAS.
  source = "${get_repo_root()}//stacks/gcp/network"

  path = "network"

  values = {
    name   = local.name
    region = "us-east1"

    subnets = {
      private = {
        ip_cidr_range = "10.0.1.0/24"
      }

      public = {
        ip_cidr_range = "10.0.101.0/24"
      }
    }

    inbound_rules = {
      allow-https = {
        priority      = 1000
        ports         = ["443"]
        source_ranges = ["0.0.0.0/0"]
        target_tags   = ["https-server"]
      }
    }
  }
}
