output "name" {
  description = "The name of the network security group"
  value       = azurerm_network_security_group.nsg.name
}

output "id" {
  description = "The ID of the network security group"
  value       = azurerm_network_security_group.nsg.id
}
