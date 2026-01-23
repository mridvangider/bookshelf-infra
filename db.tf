resource "azurerm_postgresql_flexible_server" "bookshelf_db_server" {
  location                      = azurerm_resource_group.bookshelf.location
  name                          = "bookshelf-db-server"
  resource_group_name           = azurerm_resource_group.bookshelf.name
  version                       = "18"
  delegated_subnet_id           = azurerm_subnet.bookshelf_db_subnet.id
  private_dns_zone_id           = azurerm_private_dns_zone.bookshelf_dns_zone.id
  public_network_access_enabled = false
  administrator_login           = var.bookshelf_db_admin
  administrator_password        = random_password.db_admin_password.result
  zone                          = "1"

  storage_mb   = 32768
  storage_tier = "P4"

  sku_name   = "B_Standard_B1ms"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.bookshelf_dns_link]
}

resource "azurerm_postgresql_flexible_server_database" "bookshelf_db" {
  name      = var.bookshelf_db_name
  charset   = "UTF8"
  collation = "en_US.utf8"
  server_id = azurerm_postgresql_flexible_server.bookshelf_db_server.id
}