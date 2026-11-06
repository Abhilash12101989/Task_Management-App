module "resource_group" {
  source = "../../Modules/resource_group"
  rg     = var.rg
  tags   = local.common_tags
}

module "networking" {
  source         = "../../Modules/networking"
  rg_name        = module.resource_group.rg_name
  vnet           = var.vnet
  app_subnet     = var.app_subnet
  db_subnet      = var.db_subnet
  bastion_subnet = var.bastion_subnet
  tags           = local.common_tags

  depends_on = [module.resource_group]
}

module "nsg" {
  source        = "../../Modules/nsg"
  rg_name       = module.resource_group.rg_name
  rg_location   = module.resource_group.rg_location
  nsg           = var.nsg
  tags          = local.common_tags
  app_subnet_id = module.networking.app_subnet_id

  depends_on = [module.resource_group, module.networking]
}

module "public_ip" {
  source      = "../../Modules/public_ip"
  rg_name     = module.resource_group.rg_name
  rg_location = module.resource_group.rg_location
  public_ip   = var.public_ip
  tags        = local.common_tags

  depends_on = [module.resource_group]
}

module "nat_gateway" {
  source       = "../../Modules/nat_gateway"
  rg_name      = module.resource_group.rg_name
  rg_location  = module.resource_group.rg_location
  nat_gateway  = var.nat_gateway
  public_ip_id = module.public_ip.public_ip_id
  subnet_id    = module.networking.app_subnet_id
  tags         = local.common_tags

  depends_on = [module.resource_group, module.public_ip, module.networking]
}

module "bastion" {
  source       = "../../Modules/bastion"
  rg_name      = module.resource_group.rg_name
  rg_location  = module.resource_group.rg_location
  bastion      = var.bastion
  subnet_id    = module.networking.bastion_subnet_id
  public_ip_id = module.public_ip.public_ip_id
  tags         = local.common_tags

  depends_on = [module.networking, module.public_ip]
}

module "nic" {
  source       = "../../Modules/nic"
  rg_name      = module.resource_group.rg_name
  rg_location  = module.resource_group.rg_location
  nic          = var.nic
  subnet_id    = module.networking.app_subnet_id
  public_ip_id = module.public_ip.public_ip_id
  tags         = local.common_tags

  depends_on = [module.networking, module.public_ip]
}

module "virtual_machine" {
  source      = "../../Modules/virtual_machine"
  rg_name     = module.resource_group.rg_name
  rg_location = module.resource_group.rg_location
  vm          = var.vm
  nic_id      = module.nic.nic_id
  tags        = local.common_tags

  depends_on = [module.nic]
}

module "postgresql" {
  source      = "../../Modules/postgresql"
  rg_name     = module.resource_group.rg_name
  rg_location = module.resource_group.rg_location
  vnet_id     = module.networking.vnet_id
  subnet_id   = module.networking.db_subnet_id
  postgresql  = var.postgresql
  tags        = local.common_tags

  depends_on = [module.resource_group, module.networking]
}

