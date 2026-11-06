output "nic_id" {
  description = "Map of NIC IDs keyed by nic identifier"
  value = {
    for k, v in azurerm_network_interface.nic : k => v.id
  }
}

