resource "azurerm_service_plan" "bookshelf_svc_plan" {
  name                = "bookshelf-service-plan"
  location            = azurerm_resource_group.bookshelf.location
  resource_group_name = azurerm_resource_group.bookshelf.name
  sku_name            = "B1"
  os_type             = "Linux"
}

resource "azurerm_linux_web_app" "bookshelf_app" {
  name                          = "bookshelf-app"
  location                      = azurerm_resource_group.bookshelf.location
  resource_group_name           = azurerm_resource_group.bookshelf.name
  service_plan_id               = azurerm_service_plan.bookshelf_svc_plan.id
  public_network_access_enabled = false
  virtual_network_subnet_id     = azurerm_subnet.bookshelf_app.id

  site_config {
    application_stack {
      docker_image_name   = "bookshelf:main"
      docker_registry_url = "https://${data.azurerm_container_registry.main_acr.login_server}"
    }
    always_on                                     = false
    container_registry_use_managed_identity       = true
    container_registry_managed_identity_client_id = azurerm_user_assigned_identity.app_mi.client_id
  }

  identity {
    identity_ids = [azurerm_user_assigned_identity.app_mi.id]
    type         = "UserAssigned"
  }

  app_settings = {
    "KEYVAULT_URL"   = data.azurerm_key_vault.infra_key_vault.vault_uri
    "BOOKSHELF_PORT" = tostring(var.application_port)
    "AZURE_CLIENT_ID" = azurerm_user_assigned_identity.app_mi.client_id
  }
}