output "vnet_id" {
  value       = azurerm_virtual_network.hub_vnet.id
  description = "Hub VNet Resource ID"
}

output "vnet_name" {
  value       = azurerm_virtual_network.hub_vnet.name
  description = "Hub VNet Name"
}

output "vnet_cidr" {
  value       = var.vnet_cidr
  description = "Hub VNet CIDR Block"
}

output "fw_private_ip" {
  value       = azurerm_firewall.hub_fw.ip_configuration[0].private_ip_address
  description = "Azure Firewall Private IP for Next Hop Routing"
}

output "bastion_public_ip" {
  value       = azurerm_public_ip.hub_bat_pubip.ip_address
  description = "Bastion Host Public IP for Admin Access"
}