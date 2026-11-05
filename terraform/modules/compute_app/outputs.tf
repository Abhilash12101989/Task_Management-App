output "vm_id" {
  description = "ID of Application Virtual Machine"
  value       = azurerm_linux_virtual_machine.app_vm.id
}

output "vm_name" {
  description = "Name of Application Virtual Machine"
  value       = azurerm_linux_virtual_machine.app_vm.name
}

output "public_ip_address" {
  description = "Public IP address of Application VM1"
  value       = azurerm_public_ip.app_pip.ip_address
}

output "private_ip_address" {
  description = "Private IP address of Application VM1"
  value       = azurerm_network_interface.app_nic.ip_configuration[0].private_ip_address
}

output "nic_id" {
  description = "Network Interface ID of Application VM1"
  value       = azurerm_network_interface.app_nic.id
}

