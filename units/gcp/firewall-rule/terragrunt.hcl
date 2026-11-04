include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../../..//modules/gcp/firewall-rule"
  update_source_with_cas = true
}

# The stack passes in `network` from the VPC unit.
inputs = {
  # Required inputs
  name          = values.name
  priority      = values.priority
  ports         = values.ports
  source_ranges = values.source_ranges

  # Optional inputs
  direction   = try(values.direction, "INGRESS")
  action      = try(values.action, "allow")
  protocol    = try(values.protocol, "tcp")
  target_tags = try(values.target_tags, [])
}
