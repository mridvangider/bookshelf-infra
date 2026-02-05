terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.57.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.6.0"
    }
  }
}
data "azuread_group" "deployment_principals" {
  object_id        = var.deployment_principals_object_id
  security_enabled = true
}

data "azurerm_virtual_network" "bookshelf" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

data "azurerm_subnet" "app" {
  name                 = var.app_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.bookshelf.name
}

data "azurerm_subnet" "endpoint" {
  name                 = var.endpoint_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.bookshelf.name
}

resource "azurerm_service_plan" "bookshelf_svc_plan" {
  name                = "bookshelf-service-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "B1"
  os_type             = "Linux"
}

resource "azurerm_linux_web_app" "bookshelf_app" {
  name                          = "bookshelf-app"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  service_plan_id               = azurerm_service_plan.bookshelf_svc_plan.id
  public_network_access_enabled = false
  virtual_network_subnet_id     = data.azurerm_subnet.app.id

  site_config {
    application_stack {
      docker_image_name   = "mcr/hello-world:latest"
      docker_registry_url = "https://mcr.microsoft.com/"
    }
    always_on                               = false
    container_registry_use_managed_identity = true
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_private_endpoint" "bookshelf_endpoint" {
  location            = var.location
  name                = "bookshelf_endpoint"
  resource_group_name = var.resource_group_name
  subnet_id           = data.azurerm_subnet.endpoint.id

  private_service_connection {
    name                           = "bookshelf-privateendpoint-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_linux_web_app.bookshelf_app.id
    subresource_names              = ["sites"]
  }

  private_dns_zone_group {
    name                 = "bookshelf-endpoint-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.bookshelf.id]
  }
}

resource "azuread_group_member" "app_deployment_principals" {
  group_object_id  = data.azuread_group.deployment_principals.object_id
  member_object_id = azurerm_linux_web_app.bookshelf_app.identity[0].principal_id
}

resource "azurerm_private_dns_zone" "bookshelf" {
  name                = "azurewebsites.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "bookshelf_app_dns_link" {
  name                  = "bookshelf-app-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.bookshelf.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = data.azurerm_virtual_network.bookshelf.id
}