terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.57.0"
    }
  }
}

resource "azurerm_virtual_network" "bookshelf" {
  location            = var.location
  name                = "bookshelf-vnet"
  resource_group_name = var.resource_group_name
  address_space       = [var.vnet_ip_range]
}

/*=============================*/
/* Subnets */
/*=============================*/
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.bookshelf.name
  address_prefixes     = [var.bastion_subnet_ip_range]
}

resource "azurerm_subnet" "default" {
  name                 = "default"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.bookshelf.name
  address_prefixes     = [var.default_subnet_ip_range]
}

resource "azurerm_subnet" "app" {
  name                 = "app"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.bookshelf.name
  address_prefixes     = [var.app_subnet_ip_range]
}

resource "azurerm_subnet" "db" {
  name                 = "db"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.bookshelf.name
  address_prefixes     = [var.db_subnet_ip_range]
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

/*=============================*/
/* Bastion */
/*=============================*/
resource "azurerm_public_ip" "bastion" {
  name                = "bookshelf-bastion-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bookshelf" {
  location            = var.location
  name                = "bookshelf-abastion"
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "ip-config"
    public_ip_address_id = azurerm_public_ip.bastion.id
    subnet_id            = azurerm_subnet.bastion.id
  }
}
