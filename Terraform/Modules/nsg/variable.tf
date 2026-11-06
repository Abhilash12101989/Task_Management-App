variable "nsg" {
  description = "Map of Network Security Groups with security rules"
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
}

variable "rg_name" {
  description = "Map of Resource Group names keyed by rg_key"
  type        = map(string)
}

variable "rg_location" {
  description = "Map of Resource Group locations keyed by rg_key"
  type        = map(string)
}

variable "tags" {
  description = "Tags for NSG resources"
  type        = map(string)
  default     = {}
}

variable "app_subnet_id" {
  description = "Map of application subnet IDs keyed by NSG key"
  type        = map(string)
}