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
}

variable "rg_name" {
  description = "Map of Resource Group names keyed by rg_key"
  type        = map(string)
}

variable "rg_location" {
  description = "Map of Resource Group locations keyed by rg_key"
  type        = map(string)
}

variable "nic_id" {
  description = "Map of NIC IDs keyed by nic_key"
  type        = map(string)
}

variable "tags" {
  description = "Tags for VM resources"
  type        = map(string)
  default     = {}
}
