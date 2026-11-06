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
