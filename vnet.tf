resource "azurerm_virtual_network" "bookshelf_vnet" {
  location            = azurerm_resource_group.bookshelf.location
  name                = "bookshelf-vnet"
  resource_group_name = azurerm_resource_group.bookshelf.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "bookshelf_db_subnet" {
  name                 = "bookshelf-db-subnet"
  resource_group_name  = azurerm_resource_group.bookshelf.name
  virtual_network_name = azurerm_virtual_network.bookshelf_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_private_dns_zone" "bookshelf_dns_zone" {
  name                = "bookshelf.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.bookshelf.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "bookshelf_dns_link" {
  name                  = "bookshelf-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.bookshelf_dns_zone.name
  resource_group_name   = azurerm_resource_group.bookshelf.name
  virtual_network_id    = azurerm_virtual_network.bookshelf_vnet.id
  depends_on            = [azurerm_subnet.bookshelf_db_subnet]
}