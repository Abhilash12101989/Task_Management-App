variable "rg" {
  description = "Map of resource groups to create"
  type = map(object({
    name     = string
    location = string
  }))
}

variable "vnet" {
  description = "Map of virtual networks to create"
  type = map(object({
    vnet_name          = string
    vnet_location      = string
    rg_key             = string
    vnet_address_space = list(string)
  }))
}

variable "app_subnet" {
  description = "Map of application subnets to create"
  type = map(object({
    app_subnet_name             = string
    rg_key                      = string
    vnet_key                    = string
    app_subnet_address_prefixes = list(string)
  }))
  default = {}
}

variable "db_subnet" {
  description = "Map of PostgreSQL delegated subnets to create"
  type = map(object({
    db_subnet_name             = string
    rg_key                     = string
    vnet_key                   = string
    db_subnet_address_prefixes = list(string)
  }))
  default = {}
}

variable "bastion_subnet" {
  description = "Map of Azure Bastion subnets to create"
  type = map(object({
    rg_key           = string
    vnet_key         = string
    address_prefixes = list(string)
  }))
  default = {}
}

variable "nsg" {
  description = "Map of Network Security Groups and their security rules"
  type = map(object({
    name   = string
    rg_key = string
    security_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    })), [])
  }))
  default = {}
}

variable "public_ip" {
  description = "Map of Public IPs to create"
  type = map(object({
    name              = string
    rg_key            = string
    allocation_method = string
    sku               = optional(string, "Standard")
  }))
  default = {}
}

variable "nat_gateway" {
  description = "Map of NAT Gateways to create"
  type = map(object({
    name                    = string
    rg_key                  = string
    sku_name                = optional(string, "Standard")
    idle_timeout_in_minutes = optional(number, 4)
    public_ip_key           = optional(string)
    subnet_key              = optional(string)
  }))
  default = {}
}

variable "bastion" {
  description = "Map of Azure Bastion hosts to create"
  type = map(object({
    name          = string
    rg_key        = string
    subnet_key    = string
    public_ip_key = string
    sku           = optional(string, "Basic")
  }))
  default = {}
}

variable "nic" {
  description = "Map of Network Interfaces to create"
  type = map(object({
    name                          = string
    rg_key                        = string
    subnet_key                    = string
    private_ip_address_allocation = optional(string, "Dynamic")
    public_ip_key                 = optional(string)
  }))
  default = {}
}

variable "vm" {
  description = "Map of Linux Virtual Machines to create"
  type = map(object({
    name           = string
    rg_key         = string
    nic_key        = string
    size           = optional(string, "Standard_B2s")
    admin_username = optional(string, "azureuser")
    admin_password = string
    os_disk_type   = optional(string, "Standard_LRS")
  }))
  default = {}
}

variable "postgresql" {
  description = "Map of PostgreSQL Flexible Servers to create"
  type = map(object({
    server_name                  = string
    rg_key                       = string
    vnet_key                     = string
    subnet_key                   = string
    private_dns_zone_name        = string
    admin_username               = string
    admin_password               = string
    database_name                = string
    sku_name                     = optional(string, "B_Standard_B1ms")
    version                      = optional(string, "16")
    storage_mb                   = optional(number, 32768)
    backup_retention_days        = optional(number, 7)
    geo_redundant_backup_enabled = optional(bool, false)
    zone                         = optional(string)
    collation                    = optional(string, "en_US.utf8")
    charset                      = optional(string, "utf8")
  }))
  default = {}
}

