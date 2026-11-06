output "nat_gateway_id" {
  description = "Map of NAT Gateway IDs keyed by identifier"
  value = {
    for k, v in azurerm_nat_gateway.nat : k => v.id
  }
}

