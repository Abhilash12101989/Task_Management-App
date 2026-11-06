output "resource_group_names" {
  description = "Resource Group names"
  value       = module.resource_group.rg_name
}

output "resource_group_ids" {
  description = "Resource Group IDs"
  value       = module.resource_group.rg_id
}

output "vnet_names" {
  description = "Virtual Network names"
  value       = module.networking.vnet_name
}

output "vnet_ids" {
  description = "Virtual Network IDs"
  value       = module.networking.vnet_id
}

output "app_subnet_ids" {
  description = "Application Subnet IDs"
  value       = module.networking.app_subnet_id
}

output "db_subnet_ids" {
  description = "PostgreSQL Delegated Subnet IDs"
  value       = module.networking.db_subnet_id
}

output "nsg_names" {
  description = "Network Security Group names"
  value       = module.nsg.nsg_name
}

output "nsg_ids" {
  description = "Network Security Group IDs"
  value       = module.nsg.nsg_id
}
