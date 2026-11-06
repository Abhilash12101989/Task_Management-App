resource "azurerm_nat_gateway" "nat" {
  for_each                = var.nat_gateway
  name                    = each.value.name
  location                = var.rg_location[each.value.rg_key]
  resource_group_name     = var.rg_name[each.value.rg_key]
  sku_name                = try(each.value.sku_name, "Standard")
  idle_timeout_in_minutes = try(each.value.idle_timeout_in_minutes, 4)
  tags                    = var.tags
}

# Associate NAT Gateway with a Public IP for outbound translation
resource "azurerm_nat_gateway_public_ip_association" "nat_pip_assoc" {
  for_each = {
    for k, v in var.nat_gateway : k => v if try(v.public_ip_key, null) != null
  }

  nat_gateway_id       = azurerm_nat_gateway.nat[each.key].id
  public_ip_address_id = var.public_ip_id[each.value.public_ip_key]
}

# Associate NAT Gateway with Application Subnet for outbound internet routing
resource "azurerm_subnet_nat_gateway_association" "subnet_nat_assoc" {
  for_each = {
    for k, v in var.nat_gateway : k => v if try(v.subnet_key, null) != null
  }

  subnet_id      = var.subnet_id[each.value.subnet_key]
  nat_gateway_id = azurerm_nat_gateway.nat[each.key].id
}
