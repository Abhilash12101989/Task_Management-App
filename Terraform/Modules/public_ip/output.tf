output "public_ip_id" {
  description = "Map of Public IP IDs keyed by public IP identifier"
  value = {
    for k, v in azurerm_public_ip.pip : k => v.id
  }
}

output "public_ip_address" {
  description = "Map of Public IP addresses keyed by public IP identifier"
  value = {
    for k, v in azurerm_public_ip.pip : k => v.ip_address
  }
}

