locals {
  name     = values.name
  location = values.location
  tags     = try(values.tags, {})
}

unit "resource_group" {
  // The `//` marks the repository root. That context lets each generated unit
  // properly use `update_source_with_cas` to find its relative paths within the
  // catalog and materialize them from the CAS.
  source                 = "../..//units/azure-resource-group"
  update_source_with_cas = true

  path = "resource-group"

  values = {
    name     = "${local.name}-rg"
    location = local.location
    tags     = local.tags
  }
}

unit "vnet" {
  source                 = "../..//units/azure-vnet"
  update_source_with_cas = true

  path = "vnet"

  values = {
    name          = "${local.name}-vnet"
    location      = local.location
    address_space = values.address_space
    subnets       = values.subnets
    tags          = local.tags
  }

  autoinclude {
    dependency "resource_group" {
      config_path = unit.resource_group.path

      mock_outputs = {
        name = "mock-rg"
      }
    }

    inputs = {
      resource_group_name = dependency.resource_group.outputs.name
    }
  }
}

// The NSG is attached to every subnet in the vnet, so traffic into any subnet
// goes through the rules below.
unit "nsg" {
  source                 = "../..//units/azure-nsg"
  update_source_with_cas = true

  path = "nsg"

  values = {
    name     = "${local.name}-nsg"
    location = local.location
    tags     = local.tags
  }

  autoinclude {
    dependency "resource_group" {
      config_path = unit.resource_group.path

      mock_outputs = {
        name = "mock-rg"
      }
    }

    dependency "vnet" {
      config_path = unit.vnet.path

      mock_outputs = {
        subnet_ids = {
          mock = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Network/virtualNetworks/mock-vnet/subnets/mock"
        }
      }
    }

    inputs = {
      resource_group_name = dependency.resource_group.outputs.name
      subnet_ids          = dependency.vnet.outputs.subnet_ids
    }
  }
}

unit "inbound_rule" {
  expansion {
    for_each = try(values.inbound_rules, {})
  }

  source                 = "../..//units/azure-nsg-rule"
  update_source_with_cas = true

  path = "nsg-rules/${each.key}"

  values = {
    name                   = each.key
    priority               = each.value.priority
    destination_port_range = each.value.port
    source_address_prefix  = try(each.value.source_address_prefix, "VirtualNetwork")
  }

  autoinclude {
    dependency "resource_group" {
      config_path = unit.resource_group.path

      mock_outputs = {
        name = "mock-rg"
      }
    }

    dependency "nsg" {
      config_path = unit.nsg.path

      mock_outputs = {
        name = "mock-nsg"
      }
    }

    inputs = {
      resource_group_name         = dependency.resource_group.outputs.name
      network_security_group_name = dependency.nsg.outputs.name
    }
  }
}
