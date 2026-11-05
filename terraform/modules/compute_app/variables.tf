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
  description = "Subnet ID where App VM NIC attaches"
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
  type = string
}

variable "db_private_ip" {
  description = "Private IP address of Database VM2"
  type        = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "custom_data_script_path" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

