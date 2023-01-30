#===========================================================================
# Data 
#===========================================================================
data "azurerm_client_config" "current" {
}

data "azurerm_subscription" "current" {
}

data "azurerm_virtual_network" "smc_vnet" {
  name                = var.provider_vnet_name
  resource_group_name = var.provider_smc_name
}

data "azurerm_subnet" "smc_subnet" {
  name                 = var.provider_subnet_name
  virtual_network_name = data.azurerm_virtual_network.smc_vnet.name
  resource_group_name  = var.provider_smc_name
}


data "azurerm_backup_policy_vm" "policy" {
  for_each            = { for j in local.vm_data : j.vm_name => j if j.recovery_vault_name != "" }
  name                = each.value.recovery_policy_vm
  recovery_vault_name = each.value.recovery_vault_name
  resource_group_name = each.value.recovery_vault_smc
}

data "azurerm_log_analytics_workspace" "workspace" {
  for_each            = { for j in local.vm_data : j.vm_name => j if j.workspace_name != "" }
  name                = each.value.workspace_name
  resource_group_name = each.value.workspace_smc
}

data "azurerm_application_security_group" "asg" {
  for_each            = { for j in local.vm_data : j.vm_name => j if j.asg_name != "" }
  name                = each.value.asg_name
  resource_group_name = each.value.asg_smc
}

data "azurerm_storage_account" "storage_account" {
  for_each            = { for j in local.vm_data : j.vm_name => j if j.storage_account_name != "" }
  name                = each.value.storage_account_name
  resource_group_name = each.value.storage_account_smc
}

data "azurerm_disk_encryption_set" "disk_encryption_set" {
  for_each            = { for j in local.disk_data : j.device_name => j if j.disk_encryption_set != "" }
  name                = each.value.disk_encryption_set
  resource_group_name = each.value.disk_encryption_set_smc
}

data "azurerm_key_vault" "key_vault" {
  for_each            = { for j in local.vm_data : j.vm_name => j if j.storage_account_name != "" }
  name                = each.value.key_vault
  resource_group_name = each.value.key_vault_smc
}

data "azurerm_network_security_group" "nsg" {
  for_each            = { for j in local.vm_data : j.vm_name => j if j.nsg_name != "" }
  name                = each.value.nsg_name
  resource_group_name = each.value.nsg_smc
}

/*
locals {
    sample = data.azurerm_disk_encryption_set.disk_encryption_set.id
}
*/