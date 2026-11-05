output "vm_id" {
  description = "ID of Database Virtual Machine"
  value       = azurerm_linux_virtual_machine.db_vm.id
}

output "vm_name" {
  description = "Name of Database Virtual Machine"
  value       = azurerm_linux_virtual_machine.db_vm.name
}

output "private_ip_address" {
  description = "Internal Private IP address of the Database VM"
  value       = azurerm_network_interface.db_nic.private_ip_address
}

output "nic_id" {
  description = "Network Interface ID of the Database VM"
  value       = azurerm_network_interface.db_nic.id
}

