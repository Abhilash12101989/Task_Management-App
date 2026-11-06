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

variable "rg_name" {
  description = "Map of resource group names keyed by resource group identifier"
  type        = map(string)
}

variable "rg_location" {
  description = "Map of resource group locations keyed by resource group identifier"
  type        = map(string)
}

variable "public_ip_id" {
  description = "Map of Public IP IDs keyed by public_ip_key"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "Map of Subnet IDs keyed by subnet_key"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags for NAT Gateway"
  type        = map(string)
  default     = {}
}
