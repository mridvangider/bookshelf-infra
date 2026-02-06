terraform {
  required_version = ">= 1.0.0"

  backend "azurerm" {
    use_azuread_auth     = true
    storage_account_name = "satfdata"
    container_name       = "tfstate"
    key                  = "state.tfstate"
  }

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

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

provider "azuread" {
  tenant_id = data.azurerm_client_config.current.tenant_id
}

module "network" {
  source = "./network"

  resource_group_name = var.resource_group_name
  location            = var.location
}

module "agent" {
  source = "./agent"

  resource_group_name = var.resource_group_name
  location            = var.location

  subnet_name       = module.network.default_subnet_name
  vnet_name         = module.network.vnet_name
  admin_pubkey_name = var.admin_pubkey_name

  depends_on = [module.network]
}

module "db" {
  source = "./db"

  resource_group_name = var.resource_group_name
  location            = var.location


  admin_password         = var.db_admin_password
  admin_password_version = var.db_admin_password_version
  subnet_name            = module.network.db_subnet_name
  vnet_name              = module.network.vnet_name

  depends_on = [module.agent]
}

module "web" {
  source = "./web"

  resource_group_name = var.resource_group_name
  location            = var.location


  deployment_principals_object_id = var.deployment_principals_object_id
  app_subnet_name                 = module.network.app_subnet_name
  endpoint_subnet_name            = module.network.default_subnet_name
  vnet_name                       = module.network.vnet_name

  depends_on = [module.db]
}
