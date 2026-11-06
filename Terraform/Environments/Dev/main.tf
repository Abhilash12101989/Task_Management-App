module "resource_group" {
  source = "../../Modules/resource_group"
  rg     = var.rg
  tags   = local.common_tags
}

module "networking" {
  source     = "../../Modules/networking"
  rg_name    = module.resource_group.rg_name
  vnet       = var.vnet
  app_subnet = var.app_subnet
  db_subnet  = var.db_subnet
  tags       = local.common_tags
}
