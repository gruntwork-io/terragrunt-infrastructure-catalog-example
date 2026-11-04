include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../../..//modules/gcp/monitoring-alerts"
  update_source_with_cas = true
}

# The stack passes in `resource_filter` from the unit it monitors.
inputs = {
  # Required inputs
  name          = values.name
  metric_alerts = values.metric_alerts

  # Optional inputs
  email_addresses = try(values.email_addresses, [])
  labels          = try(values.labels, {})
}
