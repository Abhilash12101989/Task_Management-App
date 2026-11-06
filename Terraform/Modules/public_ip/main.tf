resource "azurerm_public_ip" "pip" {
  for_each            = var.public_ip
  name                = each.value.name
  resource_group_name = var.rg_name[each.value.rg_key]
  location            = var.rg_location[each.value.rg_key]
  allocation_method   = each.value.allocation_method
  sku                 = each.value.sku
  tags                = var.tags
}

