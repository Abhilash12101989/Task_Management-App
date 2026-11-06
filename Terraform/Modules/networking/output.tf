output "vnet_id" {
  description = "Virtual Network IDs keyed by virtual network identifier"
  value = {
    for k, v in azurerm_virtual_network.vnet : k => v.id
  }
}

output "vnet_name" {
  description = "Virtual Network names keyed by virtual network identifier"
  value = {
    for k, v in azurerm_virtual_network.vnet : k => v.name
  }
}

output "app_subnet_id" {
  description = "Application subnet IDs keyed by subnet identifier"
  value = {
    for k, v in azurerm_subnet.app_subnet : k => v.id
  }
}

output "db_subnet_id" {
  description = "PostgreSQL delegated subnet IDs keyed by subnet identifier"
  value = {
    for k, v in azurerm_subnet.db_subnet : k => v.id
  }
}
