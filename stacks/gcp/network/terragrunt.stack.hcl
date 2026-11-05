locals {
  name   = values.name
  region = values.region
}

unit "vpc" {
  // The `//` marks the repository root. That context lets each generated unit
  // properly use `update_source_with_cas` to find its relative paths within the
  // catalog and materialize them from the CAS.
  source                 = "../../..//units/gcp/vpc"
  update_source_with_cas = true

  path = "vpc"

  values = {
    name    = "${local.name}-vpc"
    region  = local.region
    subnets = values.subnets
  }
}

// GCP firewall rules belong to the network, so each rule covers every subnet in it.
unit "inbound_rule" {
  expansion {
    for_each = try(values.inbound_rules, {})
  }

  source                 = "../../..//units/gcp/firewall-rule"
  update_source_with_cas = true

  path = "firewall-rules/${each.key}"

  values = {
    // Firewall rule names are unique across the project, so prefix them with the stack name.
    name          = "${local.name}-${each.key}"
    priority      = each.value.priority
    ports         = each.value.ports
    source_ranges = each.value.source_ranges
    target_tags   = try(each.value.target_tags, [])
  }

  autoinclude {
    dependency "vpc" {
      config_path = unit.vpc.path

      mock_outputs = {
        id = "projects/mock-project/global/networks/mock-vpc"
      }
    }

    inputs = {
      network = dependency.vpc.outputs.id
    }
  }
}
