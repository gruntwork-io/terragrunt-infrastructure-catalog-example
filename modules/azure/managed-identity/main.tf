# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE USER-ASSIGNED MANAGED IDENTITY
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_user_assigned_identity" "identity" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# GRANT THE IDENTITY ROLES ON OTHER RESOURCES
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_role_assignment" "role" {
  # The map keys are known at plan time, so the scopes can come from resources that don't exist yet.
  for_each = var.role_assignments

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = azurerm_user_assigned_identity.identity.principal_id

  # Setting the type skips the Entra ID lookup, which can fail while a new identity is still replicating.
  principal_type = "ServicePrincipal"
}
