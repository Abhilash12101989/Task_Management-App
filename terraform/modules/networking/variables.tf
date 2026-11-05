variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Azure Region for networking resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, prod)"
  type        = string
}

variable "vnet_cidr" {
  description = "Address space for the Virtual Network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "app_subnet_cidr" {
  description = "Address prefix for the Application Subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "db_subnet_cidr" {
  description = "Address prefix for the Database Subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

