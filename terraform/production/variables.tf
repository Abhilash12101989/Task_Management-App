variable "resource_group_name" {
  description = "Production Resource Group Name"
  type        = string
  default     = "rg-taskapp-prod"
}

variable "location" {
  description = "Azure Region for Production"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment identifier"
  type        = string
  default     = "production"
}

# Network
variable "vnet_cidr" {
  type    = string
  default = "10.100.0.0/16"
}

variable "lb_subnet_cidr" {
  type    = string
  default = "10.100.1.0/24"
}

variable "app_subnet_cidr" {
  type    = string
  default = "10.100.2.0/24"
}

variable "db_subnet_cidr" {
  type    = string
  default = "10.100.3.0/24"
}

# VMSS Scaling
variable "vmss_sku" {
  description = "VM Size for the Application Scale Set"
  type        = string
  default     = "Standard_B2s"
}

variable "vmss_min_instances" {
  description = "Minimum instances for High Availability"
  type        = number
  default     = 2
}

variable "vmss_max_instances" {
  description = "Maximum instances during peak traffic scale-out"
  type        = number
  default     = 5
}

variable "admin_username" {
  type    = string
  default = "azureadmin"
}

variable "ssh_public_key" {
  type    = string
  default = ""
}

# PostgreSQL Flexible Server
variable "db_sku_name" {
  description = "PostgreSQL Flexible Server SKU"
  type        = string
  default     = "B_Standard_B2s"
}

variable "db_admin_username" {
  type    = string
  default = "psqladmin"
}

