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

resource "azurerm_subnet" "bookshelf_app" {
  name                 = "bookshelf-app-subnet"
  resource_group_name  = azurerm_resource_group.bookshelf.name
  virtual_network_name = azurerm_virtual_network.bookshelf_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  delegation {
    name = "app"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.bookshelf.name
  virtual_network_name = azurerm_virtual_network.bookshelf_vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.bookshelf.name
  virtual_network_name = azurerm_virtual_network.bookshelf_vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_public_ip" "bastion" {
  name                = "bookshelf-bastion-ip"
  location            = azurerm_resource_group.bookshelf.location
  resource_group_name = azurerm_resource_group.bookshelf.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bookshelf" {
  location            = azurerm_resource_group.bookshelf.location
  name                = "bookshelf-abastion"
  resource_group_name = azurerm_resource_group.bookshelf.name

  ip_configuration {
    name                 = "ip-config"
    public_ip_address_id = azurerm_public_ip.bastion.id
    subnet_id            = azurerm_subnet.bastion.id
  }
}

resource "azurerm_private_dns_zone" "bookshelf_db_dns_zone" {
  name                = "bookshelf.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.bookshelf.name
}

resource "azurerm_private_dns_zone" "bookshelf_app_dns_zone" {
  name                = "azurewebsites.net"
  resource_group_name = azurerm_resource_group.bookshelf.name
}

resource "azurerm_private_endpoint" "bookshelf_endpoint" {
  location            = azurerm_resource_group.bookshelf.location
  name                = "bookshelf_endpoint"
  resource_group_name = azurerm_resource_group.bookshelf.name
  subnet_id           = azurerm_subnet.default.id

  private_service_connection {
    name                           = "bookshelf-privateendpoint-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_linux_web_app.bookshelf_app.id
    subresource_names              = ["sites"]
  }

  private_dns_zone_group {
    name                 = "bookshelf-endpoint-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.bookshelf_app_dns_zone.id]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "bookshelf_db_dns_link" {
  name                  = "bookshelf-db-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.bookshelf_db_dns_zone.name
  resource_group_name   = azurerm_resource_group.bookshelf.name
  virtual_network_id    = azurerm_virtual_network.bookshelf_vnet.id
  depends_on            = [azurerm_subnet.bookshelf_db_subnet]
}

resource "azurerm_private_dns_zone_virtual_network_link" "bookshelf_app_dns_link" {
  name                  = "bookshelf-app-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.bookshelf_app_dns_zone.name
  resource_group_name   = azurerm_resource_group.bookshelf.name
  virtual_network_id    = azurerm_virtual_network.bookshelf_vnet.id
  depends_on            = [azurerm_subnet.bookshelf_db_subnet, azurerm_subnet.bookshelf_app, azurerm_subnet.bastion, azurerm_subnet.default]
}