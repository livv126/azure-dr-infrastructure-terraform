output "vnet_id" {
  value       = azurerm_virtual_network.app_vnet.id
  description = "App VNet Resource ID"
}

output "vnet_name" {
  value       = azurerm_virtual_network.app_vnet.name
  description = "App VNet Name"
}

output "vnet_cidr" {
  value       = var.vnet_cidr
  description = "App VNet CIDR Block"
}

output "lb_private_ip" {
  value       = azurerm_lb.app_lb.frontend_ip_configuration[0].private_ip_address
  description = "Internal Load Balancer Private IP"
}

output "vmss_name" {
  value       = azurerm_linux_virtual_machine_scale_set.app_vmss.name
  description = "Web Server VMSS Name"
}

output "vmss_id" {
  value       = azurerm_linux_virtual_machine_scale_set.app_vmss.id
  description = "Web Server VMSS Resource ID"
}