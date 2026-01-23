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
      version = "~> 4.57.0"
    }
  }
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