variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnet_id" {
  description = "Subnet ID where the DB VM NIC will attach"
  type        = string
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key" {
  description = "OpenSSH public key"
  type        = string
}

variable "db_password" {
  description = "Database user password"
  type        = string
  sensitive   = true
}

variable "app_subnet_cidr" {
  description = "Application subnet CIDR allowed in pg_hba.conf"
  type        = string
}

variable "custom_data_script_path" {
  description = "Path to cloud-init script for DB VM"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

