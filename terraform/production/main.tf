# ==============================================================================
# Enterprise Scalable Production Architecture on Azure
# Components: Azure Load Balancer, VM Scale Set (VMSS), Autoscale, Key Vault,
# Azure Database for PostgreSQL Flexible Server, Log Analytics Workspace
# ==============================================================================

# 1. Current Client / Tenant Context
data "azurerm_client_config" "current" {}

# Random suffix for unique global resource names (Key Vault, Storage, DB)
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# 2. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Architecture = "Scalable-Production"
  }
}

# 3. Log Analytics Workspace (Centralized Telemetry)
resource "azurerm_log_analytics_workspace" "logs" {
  name                = "log-taskapp-prod-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = azurerm_resource_group.rg.tags
}

# 4. Virtual Network & Subnets
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-taskapp-prod"
  address_space       = [var.vnet_cidr]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = azurerm_resource_group.rg.tags
}

# Subnet A: Application Tier (VMSS Instances)
resource "azurerm_subnet" "app_subnet" {
  name                 = "snet-app-prod"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.app_subnet_cidr]
}

# Subnet B: Database Tier (Delegated to PostgreSQL Flexible Server)
resource "azurerm_subnet" "db_subnet" {
  name                 = "snet-db-prod"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.db_subnet_cidr]

  delegation {
    name = "fs-delegation"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# 5. Network Security Group for Application VMSS
resource "azurerm_network_security_group" "nsg_app" {
  name                = "nsg-app-prod"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-HTTP-From-LB"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Internet-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags = azurerm_resource_group.rg.tags
}

resource "azurerm_subnet_network_security_group_association" "app_nsg_assoc" {
  subnet_id                 = azurerm_subnet.app_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_app.id
}

# 6. Azure Key Vault (Secure Secret Management)
resource "azurerm_key_vault" "kv" {
  name                       = "kv-taskapp-${random_string.suffix.result}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "List", "Set", "Delete", "Purge"
    ]
  }

  tags = azurerm_resource_group.rg.tags
}

# Generate Secure Database Password
resource "random_password" "db_password" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-admin-password"
  value        = random_password.db_password.result
  key_vault_id = azurerm_key_vault.kv.id
}

# 7. Private DNS Zone for PostgreSQL Flexible Server
resource "azurerm_private_dns_zone" "dns" {
  name                = "taskapp.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
  tags                = azurerm_resource_group.rg.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "taskapp-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.rg.name
}

# 8. Enterprise Managed Database: Azure PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "db" {
  name                   = "psql-taskapp-${random_string.suffix.result}"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "16"
  delegated_subnet_id    = azurerm_subnet.db_subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.dns.id
  administrator_login    = var.db_admin_username
  administrator_password = random_password.db_password.result
  zone                   = "1"

  storage_mb   = 32768
  sku_name     = var.db_sku_name
  backup_retention_days = 7

  depends_on = [azurerm_private_dns_zone_virtual_network_link.dns_link]
  tags       = azurerm_resource_group.rg.tags
}

resource "azurerm_postgresql_flexible_server_database" "taskdb" {
  name      = "taskdb"
  server_id = azurerm_postgresql_flexible_server.db.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

# 9. Azure Standard Public Load Balancer
resource "azurerm_public_ip" "lb_pip" {
  name                = "pip-taskapp-lb-prod"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = azurerm_resource_group.rg.tags
}

resource "azurerm_lb" "lb" {
  name                = "lb-taskapp-prod"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontend"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }

  tags = azurerm_resource_group.rg.tags
}

resource "azurerm_lb_backend_address_pool" "backend_pool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "bepool-app-instances"
}

resource "azurerm_lb_probe" "health_probe" {
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "probe-http-healthz"
  protocol            = "Http"
  port                = 80
  request_path        = "/healthz"
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "http_rule" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "LBRule-HTTP-80"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend_pool.id]
  probe_id                       = azurerm_lb_probe.health_probe.id
  idle_timeout_in_minutes        = 4
  enable_floating_ip             = false
  enable_tcp_reset               = true
}

# 10. SSH Key Generation
resource "tls_private_key" "ssh" {
  count     = var.ssh_public_key == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
  ssh_pub_key = var.ssh_public_key != "" ? var.ssh_public_key : tls_private_key.ssh[0].public_key_openssh
}

# 11. Virtual Machine Scale Set (VMSS) - Scalable Application Tier
resource "azurerm_linux_virtual_machine_scale_set" "app_vmss" {
  name                = "vmss-taskapp-prod"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.vmss_sku
  instances           = var.vmss_min_instances
  admin_username      = var.admin_username

  admin_ssh_key {
    username   = var.admin_username
    public_key = local.ssh_pub_key
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "nic-vmss"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.app_subnet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.backend_pool.id]
    }
  }

  # Cloud-init to configure Nginx + Gunicorn + FastAPI connected to Flexible Server
  custom_data = base64encode(templatefile("${path.module}/../scripts/setup-app-vm.sh", {
    DB_HOST     = azurerm_postgresql_flexible_server.db.fqdn
    DB_PASSWORD = random_password.db_password.result
  }))

  upgrade_mode = "Automatic"

  tags = merge(azurerm_resource_group.rg.tags, {
    Role = "ApplicationTier"
  })
}

# 12. Horizontal Pod / VM Autoscale Setting (CPU Based)
resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "autoscale-taskapp-cpu"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.app_vmss.id

  profile {
    name = "CPUPercentageProfile"

    capacity {
      default = var.vmss_min_instances
      minimum = var.vmss_min_instances
      maximum = var.vmss_max_instances
    }

    # Scale-Out Rule: Increase instance count if CPU > 75% for 5 mins
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.app_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    # Scale-In Rule: Decrease instance count if CPU < 25% for 5 mins
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.app_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }

  tags = azurerm_resource_group.rg.tags
}

