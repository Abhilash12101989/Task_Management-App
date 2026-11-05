variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "rg-taskapp-dev"
}

variable "location" {
  description = "Azure Region for all resources"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vnet_cidr" {
  description = "Address space for the Virtual Network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "app_subnet_cidr" {
  description = "Address space for VM1 (Application Tier: Frontend + Backend)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "db_subnet_cidr" {
  description = "Address space for VM2 (Database Tier: PostgreSQL)"
  type        = string
  default     = "10.0.2.0/24"
}

variable "admin_username" {
  description = "SSH Admin username for both VMs"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "Public SSH key for authentication. If empty, an RSA key will be generated."
  type        = string
  default     = ""
}

variable "admin_ssh_ip" {
  description = "Source IP address allowed for inbound SSH access (use your public IP or * for lab)"
  type        = string
  default     = "*"
}

variable "app_vm_size" {
  description = "VM Size for VM1 Application Server (React + FastAPI)"
  type        = string
  default     = "Standard_B2s"
}

variable "db_vm_size" {
  description = "VM Size for VM2 Database Server (PostgreSQL)"
  type        = string
  default     = "Standard_B2s"
}

variable "db_password" {
  description = "PostgreSQL password for taskuser"
  type        = string
  default     = "SecureTaskPass123!"
  sensitive   = true
}

