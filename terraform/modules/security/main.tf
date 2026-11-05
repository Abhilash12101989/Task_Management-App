# Security Child Module: Application NSG, Database NSG, and Subnet Associations

# 1. NSG for Application Tier (VM 1)
resource "azurerm_network_security_group" "nsg_app" {
  name                = "nsg-app-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow HTTP
  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTPS
  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow SSH
  security_rule {
    name                       = "Allow-SSH"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.admin_ssh_ip
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Associate App NSG with App Subnet
resource "azurerm_subnet_network_security_group_association" "app_nsg_assoc" {
  subnet_id                 = var.app_subnet_id
  network_security_group_id = azurerm_network_security_group.nsg_app.id
}

# 2. NSG for Database Tier (VM 2) - Strict Network Isolation
resource "azurerm_network_security_group" "nsg_db" {
  name                = "nsg-db-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow PostgreSQL Port 5432 ONLY from Application Subnet
  security_rule {
    name                       = "Allow-Postgres-From-AppSubnet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = var.app_subnet_cidr
    destination_address_prefix = "*"
  }

  # Allow SSH strictly from Application Subnet (Jumpbox pattern)
  security_rule {
    name                       = "Allow-SSH-From-AppSubnet"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.app_subnet_cidr
    destination_address_prefix = "*"
  }

  # Deny all direct inbound internet traffic
  security_rule {
    name                       = "Deny-All-Inbound-Default"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Associate DB NSG with DB Subnet
resource "azurerm_subnet_network_security_group_association" "db_nsg_assoc" {
  subnet_id                 = var.db_subnet_id
  network_security_group_id = azurerm_network_security_group.nsg_db.id
}

