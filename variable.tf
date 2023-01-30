variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
  default     = ""
}

variable "location" {
  description = "Azure region to use. Either australiaeast or australiasoutheast"
  type        = string
  default     = "australiaeast"
}

variable "subnet_id" {
  description = "Azure Subnet ID"
  type        = string
  default     = ""
}


variable "workspace_id" {
  description = "Log analytical workspace id"
  type        = string
  default     = ""
}

variable "workspace_key" {
  description = "Log analytical workspace key"
  type        = string
  default     = ""
}

variable "dns_servers" {
  description = "(Optional) set of DNS servers to be used to configure NIC with."
  type        = list(string)
  default     = []

  /*                 {
                nic_name      =     
                domain        = CLDRMDC-MIS111.nswhealth.net	
                name          = AZUR-eHealth-AE	
                ip            = 10.134.4.135
                  },
                                    { 
                nic_name      =    
                domain        = CLDRMDC-MIS112.nswhealth.net	
                name          = AZUR-eHealth-AE	
                ip            = 10.134.4.136
                  },
                  
                {
                nic_name      =    
                domain        = CLDRMDC-MIS113.nswhealth.net	
                name          = AZUR-eHealth-AE	
                ip            = 10.134.4.143
                  }
 */

}

variable "availability_set_id" {
  description = "(Optional) The ID of the Availability Set in which the Virtual Machine should exist. Changing this forces a new resource to be created"
  type        = string
  default     = null
}

variable "zone" {
  description = "(Optional) The Zone in which this Virtual Machine should be created. Changing this forces a new resource to be created. Valid values: 1, 2, 3"
  type        = number
  default     = null
}

variable "encryption_at_host_enabled" {
  description = "(Optional) Encryption at Host disks (including the temp disk) attached to this Virtual Machine, true or false"
  type        = bool
  default     = false
}

variable "provision_vm_agent" {
  description = "(Optional) Should the Azure VM Agent be provisioned on this Virtual Machine? Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "allow_extension_operations" {
  description = "(Optional) Should Extension Operations be allowed on this Virtual Machine"
  type        = bool
  default     = true
}

variable "custom_data" {
  description = "(Optional) The base64-Encoded Custom Data which should be used for this Virtual Machine. Changing this forces a new resource to be created"
  type        = string
  default     = null
}

variable "os_disk_write_accelerator_enabled" {
  description = "write_accelerator_enabled - (Optional) Specifies if Write Accelerator is enabled on the disk. This can only be enabled on Premium_LRS managed disks with no caching and M-Series VMs. Defaults to false"
  type        = string
  default     = false
}

variable "identity" {
  description = <<EOD
Managed Identity that will be assigned to the Windows Virtual Machine.
A identity block supports the following:
  type - (Required) The type of Managed Identity which should be assigned to the Windows Virtual Machine. Possible values are SystemAssigned, UserAssigned and SystemAssigned, UserAssigned.
  identity_ids - (Optional) A list of User Managed Identity ID's which should be assigned to the Windows Virtual Machine. NOTE: This is required when type is set to UserAssigned.
EOD
  type        = any
  default     = null
}

variable "os_disk_size_gb" {
  description = "Disk size for OS disk"
  type        = string
  default     = null
}

variable "data_disk" {
  description = "Additional data disks to attach to the virtual machine."
  type        = list(map(string))
  default     = []
}

variable "patch_mode" {
  description = "Specifies the mode of in-guest patching to this Windows Virtual Machine. Possible values are Manual, AutomaticByOS and AutomaticByPlatform. Defaults to AutomaticByOS."
  type        = string
  default     = null
}

variable "license_type" {
  description = "Specifies the type of Azure Hybrid Use Benefit which should be used for this Virtual Machine. Possible values are None, Windows_Client and Windows_Server."
  type        = string
  default     = null
}

variable "os_disk" {
  description = "Optional settings related to the OS disk."
  type = object({
    caching              = string
    storage_account_type = string
    optional_settings    = map(string)
  })
  default = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    optional_settings    = {}
  }
}

variable "availability_zone" {
  description = "The availability zone the resources should be deployed to."
  type        = number
  default     = null
}

variable "provider_vnet_name" {
  description = "Provider Vnet Name"
  type        = string
  default     = ""
}

variable "provider_subnet_name" {
  description = "Provider Subnet Name"
  type        = string
  default     = ""
}

variable "provider_smc_name" {
  description = "Provider SMC Name"
  type        = string
  default     = ""
}
variable "storage_account_name" {
  description = "storage account name"
  type        = string
  default     = "storageaccountterraform"
}

variable "managed_boot_diagnostic" {
  description = "Enable managed boot diagnostics."
  type        = bool
  default     = true
}

variable "boot_diagnostic_storage_account" {
  description = "URI for the Storage Account which should be used to store Boot Diagnostics."
  type        = string
  default     = null
}

variable "vm_immutable_os_disk" {
  type        = bool
  default     = true
  description = "Delete managed OS disk when you delete the VM"
}

variable "vm_immutable_data_disk" {
  type        = bool
  default     = true
  description = "Delete managed data disk when you delete the VM"
}

variable "nic_details" {
  description = "storage account name"
  type        = string
  default     = "nic_details.csv"
}

variable "vm_details" {
  description = "storage account name"
  type        = string
  default     = "vm_details.csv"
}

variable "vm_manged_disks" {
  description = "storage account name"
  type        = string
  default     = "vm_manged_disks.csv"
}

variable "vtpm_enabled" {
  description = "vtpm enabled"
  type        = bool
  default     = false
}

variable "secure_boot_enabled" {
  description = "vtpm enabled"
  type        = bool
  default     = false
}

variable "disk_encryption_set_id" {
  description = "disk_encryption_set_id"
  type        = string
  default     = ""
}

variable "public_network_access_enabled" {
  type        = bool
  description = "public_network_access_enabled."
  default     = true
}

variable "enable_accelerated_networking" {
  type        = bool
  description = "enable_accelerated_networking."
  default     = false
}

variable "enable_ip_forwarding" {
  type        = bool
  description = "enable_ip_forwarding."
  default     = false
}

variable "private_ip_address_version" {
  type        = string
  description = "private_ip_address_version."
  default     = "IPv4"
}

variable "dedicated_host_id" {
  type        = string
  description = "The ID of a Dedicated Host where this machine should be run on. Conflicts with dedicated_host_group_id."
  default     = ""
}

/*
resource "tls_private_key" "rsa" {
  count     = var.generate_admin_ssh_key ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}
*/ 