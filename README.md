# terraform-azurerm-windows-vm-maanged-disk-2csvs

Terraform Module to create VM along with managed disks from Excel CSV

## Details

The Modules creates the following 
01.   Network Interface Card 
      -     without Public IP (As per SMC reference) 
      -     Static or Dynamic (As per requirments)
02.   NIC card association with Application Security Group
03.   NIC Card association with Network Security Group
04.   VM Availbility Set (Upcoming)
05.   Windows Virtual Machines
      -     Nic attachment to VM
      -     OS Disk
      -     Key Vault Reference
      -     Image reference
      -     Boot diagnostics
      -     Tags
06.   Managed Disk Reference with Zones
      -     With and without Disk Encryption Set
07.   Disk Association with VMs
08.   Backup of VM using Recovery Vault Protected VM policy
09.   Extension 001 - IaaSAntimalware
10.   Extension 002 - VM insights
11.   Extension 003 - Azure Ad Login for Windows
12.   Extension 004 - Azure Ad Domian Join
13.   Extension 005 - Azure Monitor Agent
14.   
## Usage

```hcl
module "Compute" {
  source              = "git::https://git.health.nsw.gov.au/ehnsw-swdcr/terraform-azurerm-windows-vm-maanged-disk-2csvs.git"

    provider_smc_name       = "Provider_SMC"        
    provider_vnet_name      = "Provider-VNET"       
    SMC_subnet_name         = "SMC_Subnet"      
    resource_group_name     = "SMC_Name"

}

Please update the both excels with required detial with above code module
```
## Extensions list details
| Extension | Description | Type | version |
|------|-------------|------|------|
JsonADDomainExtension | JsonADDomainExtension |  Microsoft.Compute.JsonADDomainExtension | 1.*|
IaaSAntimalware | IaaSAntimalware |  Microsoft.Azure.Security.IaaSAntimalware | 1.*|
MicrosoftMonitoringAgent | MicrosoftMonitoringAgent |  Microsoft.EnterpriseCloud.Monitoring.MicrosoftMonitoringAgent | 1.*|

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| azurerm | n/a |

## Modules

No Modules.

## Resources

| Name |
|------|
| [azurerm_application_security_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/application_security_group) |
| [azurerm_backup_policy_vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/backup_policy_vm) |
| [azurerm_backup_protected_vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_vm) |
| [azurerm_client_config](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) |
| [azurerm_disk_encryption_set](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/disk_encryption_set) |
| [azurerm_key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) |
| [azurerm_log_analytics_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) |
| [azurerm_managed_disk](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) |
| [azurerm_network_interface](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) |
| [azurerm_network_interface_application_security_group_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_application_security_group_association) |
| [azurerm_network_interface_security_group_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) |
| [azurerm_network_security_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/network_security_group) |
| [azurerm_storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account) |
| [azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) |
| [azurerm_subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) |
| [azurerm_virtual_machine_data_disk_attachment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) |
| [azurerm_virtual_machine_extension](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) |
| [azurerm_virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) |
| [azurerm_windows_virtual_machine](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allow\_extension\_operations | (Optional) Should Extension Operations be allowed on this Virtual Machine | `bool` | `true` | no |
| availability\_set\_id | (Optional) The ID of the Availability Set in which the Virtual Machine should exist. Changing this forces a new resource to be created | `string` | `null` | no |
| availability\_zone | The availability zone the resources should be deployed to. | `number` | `null` | no |
| boot\_diagnostic\_storage\_account | URI for the Storage Account which should be used to store Boot Diagnostics. | `string` | `null` | no |
| custom\_data | (Optional) The base64-Encoded Custom Data which should be used for this Virtual Machine. Changing this forces a new resource to be created | `string` | `null` | no |
| data\_disk | Additional data disks to attach to the virtual machine. | `list(map(string))` | `[]` | no |
| dedicated\_host\_id | The ID of a Dedicated Host where this machine should be run on. Conflicts with dedicated\_host\_group\_id. | `string` | `""` | no |
| disk\_encryption\_set\_id | disk\_encryption\_set\_id | `string` | `""` | no |
| dns\_servers | (Optional) set of DNS servers to be used to configure NIC with. | `list(string)` | `[]` | no |
| enable\_accelerated\_networking | enable\_accelerated\_networking. | `bool` | `false` | no |
| enable\_ip\_forwarding | enable\_ip\_forwarding. | `bool` | `false` | no |
| encryption\_at\_host\_enabled | (Optional) Encryption at Host disks (including the temp disk) attached to this Virtual Machine, true or false | `bool` | `false` | no |
| identity | Managed Identity that will be assigned to the Windows Virtual Machine.<br>A identity block supports the following:<br>  type - (Required) The type of Managed Identity which should be assigned to the Windows Virtual Machine. Possible values are SystemAssigned, UserAssigned and SystemAssigned, UserAssigned.<br>  identity\_ids - (Optional) A list of User Managed Identity ID's which should be assigned to the Windows Virtual Machine. NOTE: This is required when type is set to UserAssigned. | `any` | `null` | no |
| license\_type | Specifies the type of Azure Hybrid Use Benefit which should be used for this Virtual Machine. Possible values are None, Windows\_Client and Windows\_Server. | `string` | `null` | no |
| location | Azure region to use. Either australiaeast or australiasoutheast | `string` | `"australiaeast"` | no |
| managed\_boot\_diagnostic | Enable managed boot diagnostics. | `bool` | `true` | no |
| os\_disk | Optional settings related to the OS disk. | <pre>object({<br>    caching              = string<br>    storage_account_type = string<br>    optional_settings    = map(string)<br>  })</pre> | <pre>{<br>  "caching": "ReadWrite",<br>  "optional_settings": {},<br>  "storage_account_type": "Standard_LRS"<br>}</pre> | no |
| os\_disk\_size\_gb | Disk size for OS disk | `string` | `null` | no |
| os\_disk\_write\_accelerator\_enabled | write\_accelerator\_enabled - (Optional) Specifies if Write Accelerator is enabled on the disk. This can only be enabled on Premium\_LRS managed disks with no caching and M-Series VMs. Defaults to false | `string` | `false` | no |
| patch\_mode | Specifies the mode of in-guest patching to this Windows Virtual Machine. Possible values are Manual, AutomaticByOS and AutomaticByPlatform. Defaults to AutomaticByOS. | `string` | `null` | no |
| private\_ip\_address\_version | private\_ip\_address\_version. | `string` | `"IPv4"` | no |
| provider\_smc\_name | Provider SMC Name | `string` | `""` | no |
| provider\_subnet\_name | Provider Subnet Name | `string` | `""` | no |
| provider\_vnet\_name | Provider Vnet Name | `string` | `""` | no |
| provision\_vm\_agent | (Optional) Should the Azure VM Agent be provisioned on this Virtual Machine? Defaults to false. Changing this forces a new resource to be created. | `bool` | `false` | no |
| public\_network\_access\_enabled | public\_network\_access\_enabled. | `bool` | `true` | no |
| resource\_group\_name | Name of the Resource Group | `string` | `""` | no |
| secure\_boot\_enabled | vtpm enabled | `bool` | `false` | no |
| storage\_account\_name | storage account name | `string` | `"storageaccountterraform"` | no |
| subnet\_id | Azure Subnet ID | `string` | `""` | no |
| vm\_details | storage account name | `string` | `"vm_details.csv"` | no |
| vm\_immutable\_data\_disk | Delete managed data disk when you delete the VM | `bool` | `true` | no |
| vm\_immutable\_os\_disk | Delete managed OS disk when you delete the VM | `bool` | `true` | no |
| vm\_manged\_disks | storage account name | `string` | `"vm_manged_disks.csv"` | no |
| vtpm\_enabled | vtpm enabled | `bool` | `false` | no |
| workspace\_id | Log analytical workspace id | `string` | `""` | no |
| workspace\_key | Log analytical workspace key | `string` | `""` | no |
| zone | (Optional) The Zone in which this Virtual Machine should be created. Changing this forces a new resource to be created. Valid values: 1, 2, 3 | `number` | `null` | no |

## Outputs

No output.
