output "vnet_id" {
  value       = azurerm_virtual_network.data_vnet.id
  description = "Data VNet Resource ID"
}

output "vnet_name" {
  value       = azurerm_virtual_network.data_vnet.name
  description = "Data VNet Name"
}

output "db_fqdn" {
  value       = azurerm_mysql_flexible_server.mysql.fqdn
  description = "MySQL Flexible Server FQDN"
}

output "mysql_id" {
  value       = azurerm_mysql_flexible_server.mysql.id
  description = "MySQL Flexible Server Resource ID (Used as Source ID for Replica)"
}

output "dns_zone_name" {
  value       = var.dns_zone_name
  description = "MySQL Private DNS Zone Name"
}

output "private_dns_zone_id" {
  value       = var.private_dns_zone_id
  description = "MySQL Private DNS Zone Resource ID"
}

output "redis_hostname" {
  value       = var.enable_redis ? azurerm_redis_cache.redis[0].hostname : null
  description = "Redis Cache Hostname"
}

output "redis_primary_key" {
  value       = var.enable_redis ? azurerm_redis_cache.redis[0].primary_access_key : null
  sensitive   = true
  description = "Redis Cache Primary Access Key"
}