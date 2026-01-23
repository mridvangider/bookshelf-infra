resource "random_password" "db_admin_password" {
  length  = 16
  special = true

}

resource "azurerm_key_vault_secret" "db_admin_password" {
  name         = var.bookshelf_db_admin_password_key_name
  value        = random_password.db_admin_password.result
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

resource "random_password" "db_svc_password" {
  length  = 16
  special = true

}

resource "azurerm_key_vault_secret" "db_svc_password" {
  name         = var.bookshelf_db_svc_password_key_name
  value        = random_password.db_svc_password.result
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}

resource "random_password" "jwt_secret" {
  length  = 64
  special = true
}

resource "azurerm_key_vault_secret" "jwt_secret" {
  name         = var.jwt_secret_key_name
  value        = random_password.jwt_secret.result
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
}