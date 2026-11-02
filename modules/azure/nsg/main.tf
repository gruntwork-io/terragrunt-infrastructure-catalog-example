# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE NETWORK SECURITY GROUP
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_network_security_group" "nsg" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH THE NETWORK SECURITY GROUP TO SUBNETS
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_subnet_network_security_group_association" "subnet" {
  # The map keys are known at plan time, so the subnet IDs can come from resources that don't exist yet.
  for_each = var.subnet_ids

  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.nsg.id
}
