# Parent Module Outputs (Derived from Child Modules)

output "resource_group_name" {
  description = "The name of the Resource Group created"
  value       = module.networking.resource_group_name
}

output "vnet_name" {
  description = "Virtual Network Name"
  value       = module.networking.vnet_name
}

output "app_vm_public_ip" {
  description = "Public IP Address of VM1 (Frontend + Backend + Nginx)"
  value       = module.compute_app.public_ip_address
}

output "app_url" {
  description = "Application Web URL"
  value       = "http://${module.compute_app.public_ip_address}"
}

output "api_health_url" {
  description = "FastAPI Health Check Endpoint"
  value       = "http://${module.compute_app.public_ip_address}/api/health"
}

output "db_vm_private_ip" {
  description = "Private IP Address of VM2 (PostgreSQL Database)"
  value       = module.database.private_ip_address
}

output "ssh_connect_app_vm" {
  description = "SSH Command to connect to Application VM"
  value       = "ssh -i id_rsa ${var.admin_username}@${module.compute_app.public_ip_address}"
}

output "ssh_connect_db_vm_via_jumpbox" {
  description = "SSH Command to connect to DB VM using App VM as proxy/jumpbox"
  value       = "ssh -J ${var.admin_username}@${module.compute_app.public_ip_address} ${var.admin_username}@${module.database.private_ip_address}"
}

output "generated_ssh_private_key" {
  description = "Generated private SSH key (if no external key was provided)"
  value       = length(tls_private_key.ssh) > 0 ? tls_private_key.ssh[0].private_key_pem : "External key used"
  sensitive   = true
}
