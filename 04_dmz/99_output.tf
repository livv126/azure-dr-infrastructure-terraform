output "vnet_id" {
  value       = azurerm_virtual_network.dmz_vnet.id
  description = "DMZ VNet Resource ID"
}

output "vnet_name" {
  value       = azurerm_virtual_network.dmz_vnet.name
  description = "DMZ VNet Name"
}

output "vnet_cidr" {
  value       = var.vnet_cidr
  description = "DMZ VNet CIDR Block"
}

output "appgw_public_ip" {
  value       = azurerm_public_ip.pip_agw.ip_address
  description = "Application Gateway Public IP for Front Door origin"
}

output "agw_pip_id" {
  value       = azurerm_public_ip.pip_agw.id
  description = "Application Gateway Public IP Resource ID"
}