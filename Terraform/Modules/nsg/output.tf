output "nsg_name" {
  description = "Map of NSG names keyed by NSG identifier"
  value = {
    for k, v in azurerm_network_security_group.nsg : k => v.name
  }
}

output "nsg_id" {
  description = "Map of NSG IDs keyed by NSG identifier"
  value = {
    for k, v in azurerm_network_security_group.nsg : k => v.id
  }
}

