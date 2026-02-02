resource "azurerm_network_interface" "test_vm_nic" {
  location            = azurerm_resource_group.bookshelf.location
  name                = "testvm-nic"
  resource_group_name = azurerm_resource_group.bookshelf.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.default.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_linux_virtual_machine" "testvm" {
  location              = azurerm_resource_group.bookshelf.location
  name                  = "testvm"
  network_interface_ids = [azurerm_network_interface.test_vm_nic.id]
  resource_group_name   = azurerm_resource_group.bookshelf.location
  size                  = "Standard_A1_v2"
  admin_username        = "adminuser"

  admin_ssh_key {
    public_key = data.azurerm_key_vault_secret.testvm_pk.value
    username   = "adminuser"
  }

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}