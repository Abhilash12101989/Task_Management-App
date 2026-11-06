variable "bastion" {
  description = "Map of Azure Bastion hosts to create"
  type = map(object({
    name          = string
    rg_key        = string
    subnet_key    = string
    public_ip_key = string
    sku           = optional(string, "Basic")
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

variable "subnet_id" {
  description = "Map of Subnet IDs keyed by subnet_key"
  type        = map(string)
}

variable "public_ip_id" {
  description = "Map of Public IP IDs keyed by public_ip_key"
  type        = map(string)
}

variable "tags" {
  description = "Tags for Bastion resources"
  type        = map(string)
  default     = {}
}

