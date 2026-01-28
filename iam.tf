resource "azurerm_user_assigned_identity" "app_mi" {
  name                = "bookshelf-app-mi"
  resource_group_name = azurerm_resource_group.bookshelf.name
  location            = azurerm_resource_group.bookshelf.location
}

resource "azurerm_role_assignment" "bookshelf_cr_pull" {
  scope                = data.azurerm_container_registry.main_acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.app_mi.principal_id
}

resource "azurerm_role_assignment" "bookshelf_cr_read" {
  scope                = data.azurerm_container_registry.main_acr.id
  role_definition_name = "Container Registry Repository Reader"
  principal_id         = azurerm_user_assigned_identity.app_mi.principal_id
}

resource "azurerm_role_assignment" "bookshelf_kv_access" {
  scope                = data.azurerm_key_vault.infra_key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app_mi.principal_id

}