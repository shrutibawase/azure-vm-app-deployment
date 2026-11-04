output "resource_group_name" {
  description = "The name of the provisioned Azure Resource Group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "The Azure region where resources are provisioned"
  value       = azurerm_resource_group.main.location
}

output "virtual_network_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.main.name
}

output "virtual_network_id" {
  description = "The resource ID of the Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "public_subnet_id" {
  description = "The resource ID of the public subnet"
  value       = azurerm_subnet.public.id
}

output "public_ip_address" {
  description = "The static public IPv4 address assigned to the network interface"
  value       = azurerm_public_ip.main.ip_address
}

output "network_interface_id" {
  description = "The resource ID of the VM network interface"
  value       = azurerm_network_interface.main.id
}

output "vm_id" {
  description = "The resource ID of the Azure Linux Virtual Machine"
  value       = azurerm_linux_virtual_machine.main.id
}

output "vm_name" {
  description = "The hostname and resource name of the Virtual Machine"
  value       = azurerm_linux_virtual_machine.main.name
}

output "vm_private_ip" {
  description = "The private IPv4 address assigned to the Virtual Machine"
  value       = azurerm_linux_virtual_machine.main.private_ip_address
}

output "ssh_private_key_file" {
  description = "Path to the locally generated SSH private key (.pem)"
  value       = local_file.private_key.filename
}

output "ssh_command" {
  description = "Ready-to-use SSH connection command"
  value       = "ssh -i ${local_file.private_key.filename} ${var.admin_username}@${azurerm_public_ip.main.ip_address}"
}

output "cloud_init_status_command" {
  description = "Command to verify cloud-init bootstrap progress on the VM"
  value       = "ssh -i ${local_file.private_key.filename} ${var.admin_username}@${azurerm_public_ip.main.ip_address} 'sudo cat /var/log/cloud-init-output.log'"
}
