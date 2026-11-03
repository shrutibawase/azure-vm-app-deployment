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
