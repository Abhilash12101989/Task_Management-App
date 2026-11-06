variable "rg_name" {
  description = "Map of resource group names keyed by resource group identifier"
  type        = map(string)
}

variable "rg_location" {
  description = "Map of resource group locations keyed by resource group identifier"
  type        = map(string)
}

variable "vnet_id" {
  description = "Map of virtual network IDs keyed by virtual network identifier"
  type        = map(string)
}

variable "subnet_id" {
  description = "Map of delegated subnet IDs keyed by subnet identifier"
  type        = map(string)
}

variable "postgresql" {
  description = "Map of PostgreSQL Flexible Servers and databases to create"
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

variable "tags" {
  description = "Tags for PostgreSQL resources"
  type        = map(string)
  default     = {}
}

