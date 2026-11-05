variable "resource_group_name" {
  description = "Resource Group where NSGs reside"
  type        = string
}

variable "location" {
  description = "Azure Region for NSGs"
  type        = string
}

variable "environment" {
  description = "Environment identifier"
  type        = string
}

variable "app_subnet_id" {
  description = "ID of Application Subnet to associate with App NSG"
  type        = string
}

variable "db_subnet_id" {
  description = "ID of Database Subnet to associate with DB NSG"
  type        = string
}

variable "app_subnet_cidr" {
  description = "CIDR block of Application Subnet (allowed to connect to PostgreSQL)"
  type        = string
}

variable "admin_ssh_ip" {
  description = "IP address permitted for SSH access"
  type        = string
  default     = "*"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

