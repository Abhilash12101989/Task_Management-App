output "vm_id" {
  description = "Map of VM IDs keyed by vm identifier"
  value = {
    for k, v in azurerm_linux_virtual_machine.vm : k => v.id
  }
}

