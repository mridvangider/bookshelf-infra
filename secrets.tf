resource "random_password" "db_admin_password" {
  length  = 16
  special = true

}

resource "azurerm_key_vault_secret" "db_admin_password" {
  name         = var.bookshelf_db_admin_password_key_name
  value        = random_password.db_admin_password.result
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

resource "random_password" "rand_bookshelf_jwt_secret" {
  length  = 64
  special = true
}

resource "azurerm_key_vault_secret" "cfg_bookshelf_jwt_secret" {
  name         = "bookshelf-jwt-secret"
  value        = random_password.rand_bookshelf_jwt_secret.result
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

resource "random_password" "rand_spring_datasource_password" {
  length  = 64
  special = true
}

resource "azurerm_key_vault_secret" "cfg_spring_datasource_password" {
  name         = "spring-datasource-password"
  value        = random_password.rand_spring_datasource_password.result
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

resource "azurerm_key_vault_secret" "cfg_spring_datasource_url" {
  name         = "spring-datasource-url"
  value        = "jdbc:postgresql://${azurerm_postgresql_flexible_server.bookshelf_db_server.fqdn}:5432/${var.bookshelf_db_name}"
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

resource "azurerm_key_vault_secret" "cfg_spring_datasource_username" {
  name         = "spring-datasource-username"
  value        = var.bookshelf_db_svc_user
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}