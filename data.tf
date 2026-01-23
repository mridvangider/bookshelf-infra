data "azurerm_resource_group" "infra" {
  name = var.infra_rg_name
}

data "azurerm_key_vault" "infra_key_vault" {
  name                = var.infra_kv_name
  resource_group_name = data.azurerm_resource_group.infra.name
}