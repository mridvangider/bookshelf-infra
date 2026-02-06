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

/*=============================*/
/* Networking */
/*=============================*/
data "azurerm_virtual_network" "bookshelf" {
  resource_group_name = var.resource_group_name
  name                = var.vnet_name
}

data "azurerm_subnet" "db" {
  resource_group_name  = var.resource_group_name
  name                 = var.subnet_name
  virtual_network_name = data.azurerm_virtual_network.bookshelf.name
}

resource "azurerm_private_dns_zone" "db" {
  name                = "bookshelf.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "db" {
  name                  = "bookshelf-db-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.db.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = data.azurerm_virtual_network.bookshelf.id
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
  delegated_subnet_id               = data.azurerm_subnet.db.id
  private_dns_zone_id               = azurerm_private_dns_zone.db.id
  public_network_access_enabled     = false
  zone                              = "1"
  administrator_login               = var.admin_username
  administrator_password_wo         = var.admin_password
  administrator_password_wo_version = var.admin_password_version

  authentication {
    password_auth_enabled = true
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
