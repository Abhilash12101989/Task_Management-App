resource "azurerm_virtual_network" "vnet" {
  for_each            = var.vnet
  name                = each.value.vnet_name
  location            = each.value.vnet_location
  resource_group_name = var.rg_name[each.value.rg_key]
  address_space       = each.value.vnet_address_space
  tags                = var.tags
}

# Application Subnet
resource "azurerm_subnet" "app_subnet" {
  for_each             = var.app_subnet
  name                 = each.value.app_subnet_name
  resource_group_name  = var.rg_name[each.value.rg_key]
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_key].name
  address_prefixes     = each.value.app_subnet_address_prefixes
}

# PostgreSQL Delegated Subnet
resource "azurerm_subnet" "db_subnet" {
  for_each             = var.db_subnet
  name                 = each.value.db_subnet_name
  resource_group_name  = var.rg_name[each.value.rg_key]
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_key].name
  address_prefixes     = each.value.db_subnet_address_prefixes

  delegation {
    name = "postgresql-delegation"

    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"

      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

# Azure Bastion Subnet (Must be named AzureBastionSubnet, min /26)
resource "azurerm_subnet" "bastion_subnet" {
  for_each             = var.bastion_subnet
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.rg_name[each.value.rg_key]
  virtual_network_name = azurerm_virtual_network.vnet[each.value.vnet_key].name
  address_prefixes     = each.value.address_prefixes
}
