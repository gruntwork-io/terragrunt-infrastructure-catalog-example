output "name" {
  description = "The name of the managed identity"
  value       = azurerm_user_assigned_identity.identity.name
}

output "id" {
  description = "The ID of the managed identity"
  value       = azurerm_user_assigned_identity.identity.id
}

output "principal_id" {
  description = "The object ID of the managed identity's service principal"
  value       = azurerm_user_assigned_identity.identity.principal_id
}

output "client_id" {
  description = "The client ID of the managed identity"
  value       = azurerm_user_assigned_identity.identity.client_id
}

output "role_assignment_ids" {
  description = "The IDs of the role assignments, keyed by the label given in role_assignments"
  value       = { for key, assignment in azurerm_role_assignment.role : key => assignment.id }
}
