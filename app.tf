resource "azurerm_service_plan" "bookshelf_svc_plan" {
  name                = "bookshelf-service-plan"
  location            = azurerm_resource_group.bookshelf.location
  resource_group_name = azurerm_resource_group.bookshelf.name
  sku_name            = "F1"
  os_type             = "Linux"
}

resource "azurerm_linux_web_app" "bookshelf_app" {
  name                = "bookshelf-app"
  location            = azurerm_resource_group.bookshelf.location
  resource_group_name = azurerm_resource_group.bookshelf.name
  service_plan_id     = azurerm_service_plan.bookshelf_svc_plan.id

  site_config {
    application_stack {
      java_server         = "JAVA"
      java_version        = "21"
      java_server_version = "21"
    }
    always_on        = false
    app_command_line = "./startup.sh"
  }

  app_settings = {
    "KEYVAULT_URL"   = data.azurerm_key_vault.infra_key_vault.vault_uri
    "BOOKSHELF_PORT" = tostring(var.application_port)
  }
}