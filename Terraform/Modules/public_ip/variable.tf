variable "public_ip" {
  description = "Map of Public IPs to create"
  type = map(object({
    name              = string
    rg_key            = string
    allocation_method = string
    sku               = optional(string, "Standard")
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
  description = "Tags for Public IP resources"
  type        = map(string)
  default     = {}
}

