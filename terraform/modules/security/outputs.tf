output "app_nsg_id" {
  description = "ID of Application NSG"
  value       = azurerm_network_security_group.nsg_app.id
}

output "app_nsg_name" {
  description = "Name of Application NSG"
  value       = azurerm_network_security_group.nsg_app.name
}

output "db_nsg_id" {
  description = "ID of Database NSG"
  value       = azurerm_network_security_group.nsg_db.id
}

output "db_nsg_name" {
  description = "Name of Database NSG"
  value       = azurerm_network_security_group.nsg_db.name
}

