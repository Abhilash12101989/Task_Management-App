output "load_balancer_public_ip" {
  description = "Public IP Address of the Production Azure Load Balancer"
  value       = azurerm_public_ip.lb_pip.ip_address
}

output "application_url" {
  description = "Production Application Endpoint URL"
  value       = "http://${azurerm_public_ip.lb_pip.ip_address}"
}

output "key_vault_name" {
  description = "Name of the Azure Key Vault storing production secrets"
  value       = azurerm_key_vault.kv.name
}

output "database_fqdn" {
  description = "FQDN of the Azure Database for PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.db.fqdn
}

output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.logs.id
}

