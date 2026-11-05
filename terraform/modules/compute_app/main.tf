# Application Compute Child Module (VM 1: React + FastAPI + Nginx)

# Static Public IP for VM 1
resource "azurerm_public_ip" "app_pip" {
  name                = "pip-taskapp-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# Network Interface in Application Subnet
resource "azurerm_network_interface" "app_nic" {
  name                = "nic-taskapp-vm1-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app_pip.id
  }

  tags = var.tags
}

# Linux Virtual Machine for Application Tier
resource "azurerm_linux_virtual_machine" "app_vm" {
  name                  = "vm-taskapp-app-${var.environment}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.app_nic.id]

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
    DB_HOST     = var.db_private_ip
    DB_PASSWORD = var.db_password
  }))

  tags = merge(var.tags, {
    Tier = "Application"
  })
}

