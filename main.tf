terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.57.0"
    }
  }
}

resource "random_password" "db_admin_password" {
  length  = 16
  special = true

}

output "db_admin_password" {
  value       = random_password.db_admin_password
  description = "Password of the db admin"
  sensitive   = true
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "bookshelf" {
  tags = {
    project = "bookshelf"
  }
  location = var.location
  name     = "bookshelf"
}

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

resource "azurerm_postgresql_flexible_server" "bookshelf_db_server" {
  location                      = azurerm_resource_group.bookshelf.location
  name                          = "bookshelf-db-server"
  resource_group_name           = azurerm_resource_group.bookshelf.name
  version                       = "18"
  delegated_subnet_id           = azurerm_subnet.bookshelf_db_subnet.id
  private_dns_zone_id           = azurerm_private_dns_zone.bookshelf_dns_zone.id
  public_network_access_enabled = false
  administrator_login           = "bookshelf_db_admin"
  administrator_password        = random_password.db_admin_password.result
  zone                          = "1"

  storage_mb   = 32768
  storage_tier = "P4"

  sku_name   = "B_Standard_B1ms"
  depends_on = [azurerm_private_dns_zone_virtual_network_link.bookshelf_dns_link]
}
