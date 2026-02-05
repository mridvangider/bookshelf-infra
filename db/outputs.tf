output "db_server_fqdn" {
  value = azurerm_postgresql_flexible_server.bookshelf.fqdn
}

output "db_server_id" {
  value = azurerm_postgresql_flexible_server.bookshelf.id
}