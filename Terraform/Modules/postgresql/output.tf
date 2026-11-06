output "server_id" {
  description = "PostgreSQL Flexible Server IDs keyed by postgresql identifier"
  value = {
    for k, v in azurerm_postgresql_flexible_server.postgres : k => v.id
  }
}

output "server_name" {
  description = "PostgreSQL Flexible Server names keyed by postgresql identifier"
  value = {
    for k, v in azurerm_postgresql_flexible_server.postgres : k => v.name
  }
}

output "server_fqdn" {
  description = "PostgreSQL Flexible Server fully qualified domain names (FQDN) keyed by postgresql identifier"
  value = {
    for k, v in azurerm_postgresql_flexible_server.postgres : k => v.fqdn
  }
}

output "database_id" {
  description = "PostgreSQL Database IDs keyed by postgresql identifier"
  value = {
    for k, v in azurerm_postgresql_flexible_server_database.db : k => v.id
  }
}

output "database_name" {
  description = "PostgreSQL Database names keyed by postgresql identifier"
  value = {
    for k, v in azurerm_postgresql_flexible_server_database.db : k => v.name
  }
}

output "private_dns_zone_id" {
  description = "Private DNS Zone IDs keyed by postgresql identifier"
  value = {
    for k, v in azurerm_private_dns_zone.dns : k => v.id
  }
}

