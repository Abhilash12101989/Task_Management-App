# 1. Private DNS Zone for PostgreSQL Flexible Server
# Azure requires the Private DNS Zone name to end with .postgres.database.azure.com
resource "azurerm_private_dns_zone" "dns" {
  for_each            = var.postgresql
  name                = each.value.private_dns_zone_name
  resource_group_name = var.rg_name[each.value.rg_key]
  tags                = var.tags
}

# 2. Virtual Network Link for the Private DNS Zone
resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  for_each            = var.postgresql
  name                = "${each.value.server_name}-dns-link"
  private_dns_zone_id = azurerm_private_dns_zone.dns[each.key].id
  virtual_network_id  = var.vnet_id[each.value.vnet_key]
  tags                = var.tags
}

# 3. Azure PostgreSQL Flexible Server (Private Access via Delegated Subnet)
resource "azurerm_postgresql_flexible_server" "postgres" {
  for_each               = var.postgresql
  name                   = each.value.server_name
  resource_group_name    = var.rg_name[each.value.rg_key]
  location               = var.rg_location[each.value.rg_key]
  version                = try(each.value.version, "16")
  delegated_subnet_id    = var.subnet_id[each.value.subnet_key]
  private_dns_zone_id    = azurerm_private_dns_zone.dns[each.key].id
  administrator_login    = each.value.admin_username
  administrator_password = each.value.admin_password
  zone                   = try(each.value.zone, null)

  storage_mb = try(each.value.storage_mb, 32768)
  sku_name   = try(each.value.sku_name, "B_Standard_B1ms")

  backup_retention_days        = try(each.value.backup_retention_days, 7)
  geo_redundant_backup_enabled = try(each.value.geo_redundant_backup_enabled, false)

  tags = var.tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.vnet_link]
}

# 4. PostgreSQL Database for Task Management Application
resource "azurerm_postgresql_flexible_server_database" "db" {
  for_each  = var.postgresql
  name      = each.value.database_name
  server_id = azurerm_postgresql_flexible_server.postgres[each.key].id
  collation = try(each.value.collation, "en_US.utf8")
  charset   = try(each.value.charset, "utf8")
}
