output "bastion_id" {
  description = "Map of Bastion Host IDs keyed by bastion identifier"
  value = {
    for k, v in azurerm_bastion_host.bastion : k => v.id
  }
}

