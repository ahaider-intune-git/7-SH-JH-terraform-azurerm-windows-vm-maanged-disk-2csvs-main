#===========================================================================
# Locals
#===========================================================================
locals {
  vm_data   = csvdecode(file("./Files/${var.vm_details}"))
  disk_data = csvdecode(file("./Files/${var.vm_manged_disks}"))
  tag_values = flatten([
    for t in local.vm_data : [
      for s in(formatlist("%s", split(",", t.tags))) : {
        trimspace(element((formatlist("%s", split("=", s))), 0)) = trimspace(element((formatlist("%s", split("=", s))), 1))
      }
    ]
  ])
}

#===========================================================================
# Virtual Machine  - Network Interface Card - Static/Dynamic - Private/Public
#===========================================================================
resource "azurerm_network_interface" "vm_nic" {
  for_each                      = { for j in local.vm_data : trimspace(j.nic_name) => j if j.nic_name != "" }
  name                          = trimspace(each.value.nic_name)
  location                      = var.location
  resource_group_name           = var.resource_group_name
  dns_servers                   = split(",",each.value.dns_servers)
  enable_accelerated_networking = var.enable_accelerated_networking
  enable_ip_forwarding          = var.enable_ip_forwarding
  ip_configuration {
    name                          = "internal-${each.value.nic_name}"
    subnet_id                     = data.azurerm_subnet.smc_subnet.id
    private_ip_address_allocation = each.value.ip_allocation != "" ? "Static" : "Dynamic"
    public_ip_address_id          = null
    private_ip_address_version    = var.private_ip_address_version
    private_ip_address            = each.value.ip_allocation != "" ? trimspace(each.value.ip_allocation) : null
  }
}

#===========================================================================
# Network Interface with Application Security group association 
#===========================================================================
resource "azurerm_network_interface_application_security_group_association" "example" {
  for_each                      = { for j in local.vm_data : trimspace(j.nic_name) => j if j.asg_name != "" }
  network_interface_id          = azurerm_network_interface.vm_nic[each.value.nic_name].id
  application_security_group_id = data.azurerm_application_security_group.asg[trimspace(each.value.vm_name)].id
  timeouts {}
}

#===========================================================================
# Virtual Machine  - Network Interface Card - assocaition with NSG
#===========================================================================
resource "azurerm_network_interface_security_group_association" "association" {
  for_each                  = { for j in local.vm_data : trimspace(j.nic_name) => j if j.nsg_name != "" }
  network_interface_id      = azurerm_network_interface.vm_nic[each.value.nic_name].id
  network_security_group_id = data.azurerm_network_security_group.nsg[trimspace(each.value.vm_name)].id
  timeouts {}
}

#===========================================================================
# Windows Virtual Machine 
#===========================================================================
resource "azurerm_windows_virtual_machine" "terraformvm" {

  for_each            = { for j in local.vm_data : j.vm_name => j if j.vm_name != "" }
  name                = trimspace(each.value.vm_name)
  resource_group_name = trimspace(each.value.resource_group_name)
  location              = trimspace(each.value.location)
  size                  = trimspace(each.value.size)
  network_interface_ids = [azurerm_network_interface.vm_nic[each.value.nic_name].id]

  computer_name  = trimspace(each.value.computer_name)
  admin_username = trimspace(each.value.admin_username)
  admin_password = trimspace(each.value.admin_password) 

  availability_set_id        = var.availability_set_id
  zone                       = each.value.zones != "" ? trimspace(each.value.zones) : null
  encryption_at_host_enabled = var.encryption_at_host_enabled
  allow_extension_operations = var.allow_extension_operations
  custom_data                = var.custom_data
  license_type               = each.value.license_type != "" ? trimspace(each.value.license_type) : null
  patch_mode                 = trimspace(each.value.patch_mode)

  dynamic "identity" {
    for_each = var.identity != null ? [1] : []
    content {
      type         = var.identity.type
      identity_ids = lookup(var.identity, "identity_ids", null)
      #principal_id = var.principal_id
      #tenant_id = var.tenant_id
    }
  }
  os_disk {
    name                      = trimspace(each.value.os_disk_name)
    caching                   = trimspace(each.value.os_disk_caching)
    storage_account_type      = trimspace(each.value.os_storage_account_type)
    disk_size_gb              = each.value.os_disk_size_gb
    disk_encryption_set_id    = lookup(var.os_disk.optional_settings, "disk_encryption_set_id", null)
    write_accelerator_enabled = var.os_disk_write_accelerator_enabled
  }

  dynamic "boot_diagnostics" {
    for_each = var.managed_boot_diagnostic ? ["true"] : []
    content {
      storage_account_uri = each.value.storage_account_name != "" ? data.azurerm_storage_account.storage_account[trimspace(each.value.vm_name)].primary_blob_endpoint : ""
    }
  }
  #source_image_reference {}
  source_image_id = each.value.source_image_id != "" ? format("/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Compute/images/%s", data.azurerm_subscription.current.subscription_id, each.value.image_smc, each.value.source_image_id) : null

  # Only one of source_image_id or source_image_reference can be used . 
  /* dynamic "source_image_reference" {
    for_each = each.value.source_image_id != null ? [1] : []
    content {
      publisher = try(each.value.image_publisher, null)
      offer     = try(each.value.image_offer, null)
      sku       = try(each.value.image_sku, null)
      version   = try(each.value.image_version, null)
    }
  }
*/

  enable_automatic_updates = lower(each.value.enable_automatic_updates)
  provision_vm_agent       = true
  tags = each.value.tags != "" ? zipmap(
    flatten(
      [for item in flatten([
        for s in(formatlist("%s", split(",", each.value.tags))) : {
          trimspace(element((formatlist("%s", split("=", s))), 0)) = trimspace(element((formatlist("%s", split("=", s))), 1))
        }
      ]) : keys(item)]
    ),

    flatten(
      [for item in flatten([
        for s in(formatlist("%s", split(",", each.value.tags))) : {
          trimspace(element((formatlist("%s", split("=", s))), 0)) = trimspace(element((formatlist("%s", split("=", s))), 1))
        }
      ]) : values(item)]
    )
  ) : {}

  secure_boot_enabled = var.secure_boot_enabled
  vtpm_enabled        = var.vtpm_enabled
  timeouts {}
  depends_on = [azurerm_network_interface.vm_nic]
}

#===========================================================================
# Azure Managed Disks
#===========================================================================
resource "azurerm_managed_disk" "az_managed_disk" {
  for_each                      = { for j in local.disk_data : j.device_name => j if j.vm_name != "" }
  name                          = trimspace(each.value.device_name)
  resource_group_name           = trimspace(each.value.managed_disk_resource_group_name)
  location                      = var.location
  storage_account_type          = trimspace(each.value.storage_account_type)
  disk_size_gb                  = trimspace(each.value.disk_size_gb)
  zone                          = each.value.zones != "" ? each.value.zones : null #each.value.zones != "" ? tolist(each.value.zones) : null
  create_option                 = trimspace(each.value.create_option)
  disk_encryption_set_id        = trimspace(each.value.disk_encryption_set) != "" ? data.azurerm_disk_encryption_set.disk_encryption_set[trimspace(each.value.device_name)].id : null
  public_network_access_enabled = var.public_network_access_enabled

  # If create_option is anything other than Empty,
  # we need to define the supporting attribute.
  source_resource_id = contains(["copy", "restore"], lower(each.value.create_option)) ? each.value.additional_settings.source_resource_id : null
  source_uri         = lower(each.value.create_option) == "import" ? each.value.additional_settings.source_uri : null
  image_reference_id = lower(each.value.create_option) == "fromimage" ? each.value.additional_settings.image_reference_id : null
  depends_on         = [azurerm_windows_virtual_machine.terraformvm]
  tags               = {}
  timeouts {}
}

#===========================================================================
# Azure Managed Disks - Attach the Disk to the VMs
#===========================================================================
resource "azurerm_virtual_machine_data_disk_attachment" "az_vm_disk_attachment" {
  for_each                  = { for j in local.disk_data : join("-", [j.vm_name], [j.device_name]) => j if j.vm_name != "" }
  managed_disk_id           = azurerm_managed_disk.az_managed_disk[trimspace(each.value.device_name)].id
  virtual_machine_id        = azurerm_windows_virtual_machine.terraformvm[trimspace(each.value.vm_name)].id
  lun                       = tonumber(trimspace(trimspace(each.value.lun)))
  caching                   = trimspace(each.value.caching)
  write_accelerator_enabled = lookup(each.value, "write_accelerator_enabled", null)
  depends_on                = [azurerm_managed_disk.az_managed_disk]
  timeouts {}
}

#===================================================================
# VM backup to Recovery vault based on VM backup Policy
#===================================================================
resource "azurerm_backup_protected_vm" "machine" {
  for_each            = { for j in local.vm_data : j.vm_name => j if j.recovery_vault_name != "" }
  resource_group_name = each.value.recovery_vault_smc
  recovery_vault_name = each.value.recovery_vault_name
  backup_policy_id    = data.azurerm_backup_policy_vm.policy[trimspace(each.value.vm_name)].id
  source_vm_id        = azurerm_windows_virtual_machine.terraformvm[trimspace(each.value.vm_name)].id
  depends_on          = [azurerm_windows_virtual_machine.terraformvm]
}

#===================================================================
# VM extension 01 - IaaSAntimalware
#===================================================================
resource "azurerm_virtual_machine_extension" "IaaSAntimal" {
  for_each                   = { for j in local.vm_data : j.vm_name => j if j.ext01_IaaSAntimal != "" }
  name                       = trimspace(each.value.ext01_IaaSAntimal)
  virtual_machine_id         = azurerm_windows_virtual_machine.terraformvm[each.value.vm_name].id
  publisher                  = "Microsoft.Azure.Security"
  type                       = "IaaSAntimalware"
  type_handler_version       = "1.1"
  auto_upgrade_minor_version = "true"
  depends_on                 = [azurerm_windows_virtual_machine.terraformvm]

  # Values can be changed based on the requirment
  settings = <<SETTINGS
    {
    "AntimalwareEnabled": true,
    "RealtimeProtectionEnabled": "true",
    "ScheduledScanSettings": {
    "isEnabled": "true",
    "day": "1",
    "time": "120",
    "scanType": "Quick"
    },
    "Exclusions": {
    "Extensions": "",
    "Paths": "",
    "Processes": ""
    }
    }
  SETTINGS
  tags     = {}
  timeouts {}
}

#===================================================================
# VM extension 02 - VM insights
#===================================================================

resource "azurerm_virtual_machine_extension" "MSM_Agent" {
  for_each = { for j in local.vm_data : j.vm_name => j if j.ext02_MSMAgent != "" }
  name     = trimspace(each.value.ext02_MSMAgent) #each.value.ext02_MSMAgent
  virtual_machine_id   = azurerm_windows_virtual_machine.terraformvm[each.value.vm_name].id
  publisher            = "Microsoft.EnterpriseCloud.Monitoring"
  type                 = "MicrosoftMonitoringAgent"
  type_handler_version = "1.0"
  #automatic_upgrade_enabled  = null     #Automatic extension upgrade is not supported for this extension
  depends_on = [azurerm_windows_virtual_machine.terraformvm]

  auto_upgrade_minor_version = true
  settings = jsonencode(
    {
      "workspaceId" : data.azurerm_log_analytics_workspace.workspace[trimspace(each.value.vm_name)].workspace_id
    }
  )
  protected_settings = jsonencode(
    {
      "workspaceKey" : data.azurerm_log_analytics_workspace.workspace[trimspace(each.value.vm_name)].primary_shared_key
    }
  )
  tags = {}
  timeouts {}
}

#===================================================================
# VM extension 03 - Azure Ad Login for Windows
#===================================================================
resource "azurerm_virtual_machine_extension" "azure_ad_login" {
  for_each = { for j in local.vm_data : j.vm_name => j if j.ext03_ADlogin != "" }
  name                 = trimspace(each.value.ext03_ADlogin)
  virtual_machine_id   = azurerm_windows_virtual_machine.terraformvm[each.value.vm_name].id
  publisher            = "Microsoft.Azure.ActiveDirectory"
  type                 = "AADLoginForWindows"
  type_handler_version = "1.0"
  depends_on = [azurerm_windows_virtual_machine.terraformvm]
  tags       = {}
  timeouts {}
}

#===================================================================
# VM extension 04 - Azure Ad Domian Join 
#===================================================================
resource "azurerm_virtual_machine_extension" "adjoin" {
  for_each             = { for j in local.vm_data : j.vm_name => j if j.ext04_ADJoin != "" }
  name                 = format("%s-adjoin", each.value.vm_name)
  virtual_machine_id   = azurerm_windows_virtual_machine.terraformvm[each.value.vm_name].id
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"

  settings           = <<SETTINGS
    {
        "Name": "${each.value.adjoin_name}",				
        "User": "${each.value.adjoin_users}",
        "OUPath": "${each.value.adjoin_oupath}",
        "Restart": "${each.value.adjoin_restart}",
        "Options": "${each.value.adjoin_options}"
    }
SETTINGS
  protected_settings = <<PROTECTED_SETTINGS
    {
      "Password": "adjoin_password"
    }
  PROTECTED_SETTINGS
  depends_on         = [azurerm_windows_virtual_machine.terraformvm]
  tags               = {}
  timeouts {}
}

#===================================================================
# VM extension 05 - Azure Monitor Agent
#===================================================================
resource "azurerm_virtual_machine_extension" "azure_monitor_agent" {
  for_each             = { for j in local.vm_data : j.vm_name => j if j.ext05_AMA != "" }
  name                 = trimspace(each.value.vm_name)
  virtual_machine_id   = azurerm_windows_virtual_machine.terraformvm[each.value.vm_name].id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorWindowsAgent"
  type_handler_version = "1.2"
  depends_on           = [azurerm_windows_virtual_machine.terraformvm]
  tags                 = {}
  timeouts {}
}

#===========================================================================
# Install Softwares on VM
#===========================================================================

