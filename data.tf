data "azurerm_resource_group" "infra" {
  name = var.infra_rg_name
}

data "azurerm_key_vault" "infra_key_vault" {
  name                = var.infra_kv_name
  resource_group_name = data.azurerm_resource_group.infra.name
}

data "azurerm_container_registry" "main_acr" {
  name                = var.main_acr_name
  resource_group_name = data.azurerm_resource_group.infra.name
}

data "azurerm_key_vault_secret" "testvm_pk" {
  key_vault_id = data.azurerm_key_vault.infra_key_vault.id
  name         = "testvm-pk"
}