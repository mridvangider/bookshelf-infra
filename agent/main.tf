terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.57.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.7.0"
    }
  }
}

data "azurerm_ssh_public_key" "admin" {
  resource_group_name = var.resource_group_name
  name                = var.agent_admin_pubkey_name
}

resource "azurerm_network_interface" "agent" {
  location            = var.location
  name                = "agentvm-nic"
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.agent_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "agent" {
  location              = var.location
  name                  = "agentvm"
  network_interface_ids = [azurerm_network_interface.agent.id]
  resource_group_name   = var.resource_group_name
  size                  = var.agent_vm_size
  admin_username        = var.agent_admin_user

  admin_ssh_key {
    public_key = data.azurerm_ssh_public_key.admin.public_key
    username   = var.agent_admin_user
  }

  identity {
    type = "SystemAssigned"
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

resource "azurerm_virtual_machine_extension" "entra_login" {
  name                 = "entra-ssh-login"
  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = "AADSSHLoginForLinux"
  type_handler_version = "1.0.3307.1"
  virtual_machine_id   = azurerm_linux_virtual_machine.agent.id
}

data "azuread_group" "bookshelf_db_admins" {
  object_id        = var.bookshelf_db_admin_group_object_id
  security_enabled = true
}

resource "azuread_group_member" "agent_db_admin" {
  group_object_id  = data.azuread_group.bookshelf_db_admins.object_id
  member_object_id = azurerm_linux_virtual_machine.agent.identity[0].principal_id
}