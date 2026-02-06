terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.57.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.6.0"
    }
  }
}

data "local_file" "agent_pubkey" {
  filename = var.admin_pubkey_path
}

data "azurerm_subnet" "agent" {
  resource_group_name  = var.resource_group_name
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
}

resource "azurerm_network_interface" "agent" {
  location            = var.location
  name                = "agentvm-nic"
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.agent.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "agent" {
  location              = var.location
  name                  = "agentvm"
  network_interface_ids = [azurerm_network_interface.agent.id]
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_user

  admin_ssh_key {
    public_key = data.local_file.agent_pubkey.content
    username   = var.admin_user
  }

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-13"
    sku       = "13-gen2"
    version   = "0.20260129.2372"
  }
}
