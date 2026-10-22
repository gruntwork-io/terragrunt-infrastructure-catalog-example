include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../..//modules/azure-nsg-rule"
  update_source_with_cas = true
}

# The stack wires in `resource_group_name` and `network_security_group_name` from the resource group and NSG units.
inputs = {
  # Required inputs
  name                   = values.name
  priority               = values.priority
  destination_port_range = values.destination_port_range

  # Optional inputs
  direction                  = try(values.direction, "Inbound")
  access                     = try(values.access, "Allow")
  protocol                   = try(values.protocol, "Tcp")
  source_address_prefix      = try(values.source_address_prefix, "VirtualNetwork")
  destination_address_prefix = try(values.destination_address_prefix, "*")
}
