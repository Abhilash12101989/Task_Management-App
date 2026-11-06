resource "azurerm_network_security_group" "nsg" {
  for_each            = var.nsg
  name                = each.value.name
  location            = var.rg_location[each.value.rg_key]
  resource_group_name = var.rg_name[each.value.rg_key]
  tags                = var.tags

  dynamic "security_rule" {
    for_each = each.value.security_rules != null ? each.value.security_rules : []
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

# Associate NSG with Application Subnet

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  for_each = var.nsg

  subnet_id = var.app_subnet_id[each.key]

  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}
