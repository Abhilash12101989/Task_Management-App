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

output "bastion_subnet_ids" {
  description = "Azure Bastion Subnet IDs"
  value       = module.networking.bastion_subnet_id
}

output "nsg_names" {
  description = "Network Security Group names"
  value       = module.nsg.nsg_name
}

output "nsg_ids" {
  description = "Network Security Group IDs"
  value       = module.nsg.nsg_id
}

output "public_ip_ids" {
  description = "Public IP IDs"
  value       = module.public_ip.public_ip_id
}

output "public_ip_addresses" {
  description = "Public IP Addresses"
  value       = module.public_ip.public_ip_address
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs"
  value       = module.nat_gateway.nat_gateway_id
}

output "bastion_ids" {
  description = "Azure Bastion Host IDs"
  value       = module.bastion.bastion_id
}

output "nic_ids" {
  description = "Network Interface IDs"
  value       = module.nic.nic_id
}

output "vm_ids" {
  description = "Linux Virtual Machine IDs"
  value       = module.virtual_machine.vm_id
}

output "postgresql_server_ids" {
  description = "PostgreSQL Flexible Server IDs"
  value       = module.postgresql.server_id
}

output "postgresql_server_fqdns" {
  description = "PostgreSQL Flexible Server FQDNs"
  value       = module.postgresql.server_fqdn
}

output "postgresql_database_names" {
  description = "PostgreSQL Database names"
  value       = module.postgresql.database_name
}

output "postgresql_private_dns_zone_ids" {
  description = "PostgreSQL Private DNS Zone IDs"
  value       = module.postgresql.private_dns_zone_id
}

