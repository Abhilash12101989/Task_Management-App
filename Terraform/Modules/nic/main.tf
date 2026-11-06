resource "azurerm_network_interface" "nic" {
  for_each            = var.nic
  name                = each.value.name
  location            = var.rg_location[each.value.rg_key]
  resource_group_name = var.rg_name[each.value.rg_key]
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id[each.value.subnet_key]
    private_ip_address_allocation = try(each.value.private_ip_address_allocation, "Dynamic")
    public_ip_address_id          = try(var.public_ip_id[each.value.public_ip_key], null)
  }
}

