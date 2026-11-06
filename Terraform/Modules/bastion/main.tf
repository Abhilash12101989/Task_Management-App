resource "azurerm_bastion_host" "bastion" {
  for_each            = var.bastion
  name                = each.value.name
  location            = var.rg_location[each.value.rg_key]
  resource_group_name = var.rg_name[each.value.rg_key]
  sku                 = try(each.value.sku, "Basic")
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.subnet_id[each.value.subnet_key]
    public_ip_address_id = var.public_ip_id[each.value.public_ip_key]
  }
}

