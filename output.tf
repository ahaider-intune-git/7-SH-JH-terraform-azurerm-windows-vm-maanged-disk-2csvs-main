/*output "id" {
  description = "The storage account resource id"
  value       = azurerm_windows_virtual_machine.terraformvm.*.id
}

output "id_map" {
  description = "The storage account resource id"
  value       = { for p in azurerm_windows_virtual_machine.terraformvm : p.id => p } 
}

*/
  output "Virtual_Machines_IDs" {
    description = "Virtual Machines IDs"
    value       = { for p in azurerm_windows_virtual_machine.terraformvm : p.id => p }
    sensitive   = true
  }

  output "Virtual_Machines_Names" {
    description = "Virtual Machines Names"
    value       = { for p in azurerm_windows_virtual_machine.terraformvm : p.name => p }
    sensitive   = true
  }