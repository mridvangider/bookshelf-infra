terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.57.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.7.2"
    }
  }
}

data "azurerm_client_config" "current" {}

/*=============================*/
/* Networking */
/*=============================*/
resource "azurerm_private_dns_zone" "db" {
  name                = "bookshelf.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "db" {
  name                  = "bookshelf-db-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.db.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = var.vnet_id
  registration_enabled  = true
}

/*=============================*/
/* Postgres */
/*=============================*/
resource "azurerm_postgresql_flexible_server" "bookshelf" {
  location                          = var.location
  name                              = "bookshelf-db-server"
  resource_group_name               = var.resource_group_name
  version                           = var.pg_version
  delegated_subnet_id               = var.subnet_id
  private_dns_zone_id               = azurerm_private_dns_zone.db.id
  public_network_access_enabled     = false
  zone                              = "1"
  administrator_login               = var.admin_username
  administrator_password_wo         = var.admin_password
  administrator_password_wo_version = var.admin_password_version

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }

  storage_mb   = 32768
  storage_tier = "P4"

  sku_name   = "B_Standard_B1ms"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.db]
}

resource "azurerm_postgresql_flexible_server_database" "bookshelf" {
  name      = var.db_name
  charset   = "UTF8"
  collation = "en_US.utf8"
  server_id = azurerm_postgresql_flexible_server.bookshelf.id
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "bookshelf" {
  object_id           = var.entra_admin_object_id
  principal_name      = var.entra_admin_name
  principal_type      = var.entra_admin_principal_type
  resource_group_name = var.resource_group_name
  server_name         = azurerm_postgresql_flexible_server.bookshelf.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
}