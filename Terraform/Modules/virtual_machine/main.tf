resource "azurerm_linux_virtual_machine" "vm" {
  for_each                        = var.vm
  name                            = each.value.name
  resource_group_name             = var.rg_name[each.value.rg_key]
  location                        = var.rg_location[each.value.rg_key]
  size                            = try(each.value.size, "Standard_B2s")
  admin_username                  = try(each.value.admin_username, "azureuser")
  admin_password                  = each.value.admin_password
  disable_password_authentication = false
  network_interface_ids           = [var.nic_id[each.value.nic_key]]
  tags                            = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = try(each.value.os_disk_type, "Standard_LRS")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
