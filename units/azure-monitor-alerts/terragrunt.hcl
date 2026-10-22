include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../..//modules/azure-monitor-alerts"
  update_source_with_cas = true
}

# The stack wires in `resource_group_name` and `target_resource_id` from the units it monitors.
inputs = {
  # Required inputs
  name             = values.name
  metric_namespace = values.metric_namespace
  metric_alerts    = values.metric_alerts

  # Optional inputs
  email_addresses = try(values.email_addresses, [])
  tags            = try(values.tags, {})
}
