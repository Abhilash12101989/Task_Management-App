# ==============================================================================
# Parent (Root) Terraform Module: Three-Tier Task Management App on Azure
# Consumes Reusable Child Modules: networking, security, database_vm, compute_app
# ==============================================================================

locals {
  common_tags = {
    Project     = "ThreeTierTaskApp"
    Environment = var.environment
    ManagedBy   = "Terraform-Modules"
  }
}

# 1. SSH Key Generation (Parent utility if no public key provided)
resource "tls_private_key" "ssh" {
  count     = var.ssh_public_key == "" ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
  ssh_pub_key = var.ssh_public_key != "" ? var.ssh_public_key : tls_private_key.ssh[0].public_key_openssh
}

# 2. Child Module: Networking (VNet, Subnets, Resource Group)
module "networking" {
  source              = "./modules/networking"
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
  vnet_cidr           = var.vnet_cidr
  app_subnet_cidr     = var.app_subnet_cidr
  db_subnet_cidr      = var.db_subnet_cidr
  tags                = local.common_tags
}

# 3. Child Module: Security (NSGs, Rules, Subnet Associations)
module "security" {
  source              = "./modules/security"
  resource_group_name = module.networking.resource_group_name
  location            = module.networking.resource_group_location
  environment         = var.environment
  app_subnet_id       = module.networking.app_subnet_id
  db_subnet_id        = module.networking.db_subnet_id
  app_subnet_cidr     = module.networking.app_subnet_cidr
  admin_ssh_ip        = var.admin_ssh_ip
  tags                = local.common_tags
}

# 4. Child Module: Database Tier (VM 2: PostgreSQL Server)
module "database" {
  source                  = "./modules/database_vm"
  resource_group_name     = module.networking.resource_group_name
  location                = module.networking.resource_group_location
  environment             = var.environment
  subnet_id               = module.networking.db_subnet_id
  vm_size                 = var.db_vm_size
  admin_username          = var.admin_username
  ssh_public_key          = local.ssh_pub_key
  db_password             = var.db_password
  app_subnet_cidr         = module.networking.app_subnet_cidr
  custom_data_script_path = "${path.module}/scripts/setup-db-vm.sh"
  tags                    = local.common_tags

  depends_on = [module.security]
}

# 5. Child Module: Application Tier (VM 1: React + FastAPI + Nginx)
module "compute_app" {
  source                  = "./modules/compute_app"
  resource_group_name     = module.networking.resource_group_name
  location                = module.networking.resource_group_location
  environment             = var.environment
  subnet_id               = module.networking.app_subnet_id
  vm_size                 = var.app_vm_size
  admin_username          = var.admin_username
  ssh_public_key          = local.ssh_pub_key
  db_private_ip           = module.database.private_ip_address
  db_password             = var.db_password
  custom_data_script_path = "${path.module}/scripts/setup-app-vm.sh"
  tags                    = local.common_tags

  depends_on = [module.database, module.security]
}
