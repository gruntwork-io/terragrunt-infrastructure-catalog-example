output "name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  description = "The IDs of the subnets, keyed by subnet name"
  value       = { for name, subnet in azurerm_subnet.subnet : name => subnet.id }
}
