output "vnet_name" {
  value = azurerm_virtual_network.bookshelf.name
}

output "vnet_id" {
  value = azurerm_virtual_network.bookshelf.id
}

output "bastion_name" {
  value = azurerm_bastion_host.bookshelf.name
}

output "default_subnet_name" {
  value = azurerm_subnet.default.name
}

output "db_subnet_name" {
  value = azurerm_subnet.db.name
}

output "app_subnet_name" {
  value = azurerm_subnet.app.name
}
