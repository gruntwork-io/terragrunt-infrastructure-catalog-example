# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE VIRTUAL NETWORK
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_virtual_network" "vnet" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  tags                = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE SUBNETS
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes
}
