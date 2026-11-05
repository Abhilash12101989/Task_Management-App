output "resource_group_name" {
  description = "Name of the created Resource Group"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  description = "Location of the created Resource Group"
  value       = azurerm_resource_group.rg.location
}

output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.vnet.name
}

output "app_subnet_id" {
  description = "ID of the Application Subnet"
  value       = azurerm_subnet.app_subnet.id
}

output "app_subnet_cidr" {
  description = "CIDR prefix of the Application Subnet"
  value       = var.app_subnet_cidr
}

output "db_subnet_id" {
  description = "ID of the Database Subnet"
  value       = azurerm_subnet.db_subnet.id
}

output "db_subnet_cidr" {
  description = "CIDR prefix of the Database Subnet"
  value       = var.db_subnet_cidr
}

