# Database VM Child Module (VM 2: PostgreSQL Server)

# Private NIC in Database Subnet (No Public IP)
resource "azurerm_network_interface" "db_nic" {
  name                = "nic-taskapp-vm2-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# Linux Virtual Machine for PostgreSQL
resource "azurerm_linux_virtual_machine" "db_vm" {
  name                  = "vm-taskapp-db-${var.environment}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.db_nic.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(templatefile(var.custom_data_script_path, {
    DB_PASSWORD     = var.db_password
    APP_SUBNET_CIDR = var.app_subnet_cidr
  }))

  tags = merge(var.tags, {
    Tier = "Database"
  })
}

