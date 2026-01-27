resource "azurerm_service_plan" "bookshelf_svc_plan" {
  name                = "bookshelf-service-plan"
  location            = azurerm_resource_group.bookshelf.location
  resource_group_name = azurerm_resource_group.bookshelf.name
  sku_name            = "F1"
  os_type             = "Linux"
}

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

resource "azurerm_role_assignment" "bookshelf_kv_access" {
  scope                = data.azurerm_key_vault.infra_key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app_mi.principal_id

}

resource "azurerm_linux_web_app" "bookshelf_app" {
  name                = "bookshelf-app"
  location            = azurerm_resource_group.bookshelf.location
  resource_group_name = azurerm_resource_group.bookshelf.name
  service_plan_id     = azurerm_service_plan.bookshelf_svc_plan.id

  site_config {
    application_stack {
      docker_registry_url = "https://mcr.microsoft.com"
      docker_image_name   = "appsvc/staticsite:latest"
    }
    always_on                                     = false
    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = azurerm_user_assigned_identity.app_mi.client_id
  }

  identity {
    identity_ids = [azurerm_user_assigned_identity.app_mi]
    type         = "UserAssigned"
  }

  app_settings = {
    "KEYVAULT_URL"   = data.azurerm_key_vault.infra_key_vault.vault_uri
    "BOOKSHELF_PORT" = tostring(var.application_port)
  }
}