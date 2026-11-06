output "rg_name" {
  description = "Map of resource group names"
  value = {
    for k, v in azurerm_resource_group.rg : k => v.name
  }
}

output "rg_location" {
  description = "Map of resource group locations"
  value = {
    for k, v in azurerm_resource_group.rg : k => v.location
  }
}

output "rg_id" {
  description = "Map of resource group IDs"
  value = {
    for k, v in azurerm_resource_group.rg : k => v.id
  }
}
