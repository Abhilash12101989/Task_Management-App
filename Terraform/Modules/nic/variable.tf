variable "nic" {
  description = "Map of Network Interfaces to create"
  type = map(object({
    name                          = string
    rg_key                        = string
    subnet_key                    = string
    private_ip_address_allocation = optional(string, "Dynamic")
    public_ip_key                 = optional(string)
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
  default     = {}
}

variable "tags" {
  description = "Tags for Network Interfaces"
  type        = map(string)
  default     = {}
}

