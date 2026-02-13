output "log_analytics_id" {
  value       = azurerm_log_analytics_workspace.law.id
  description = "Central Log Analytics Workspace ID"
}

output "ssh_public_key" {
  value       = tls_private_key.global_key.public_key_openssh
  description = "SSH public key for VM authentication"
}

output "ssh_private_key" {
  value       = tls_private_key.global_key.private_key_pem
  sensitive   = true
  description = "SSH private key for Bastion initialization"
}

output "db_username" {
  value       = azurerm_key_vault_secret.db_user.value
  description = "DB Admin Username"
}

output "db_password" {
  value       = azurerm_key_vault_secret.db_pass.value
  sensitive   = true
  description = "DB Admin Password"
}

output "firewall_policy_id" {
  value       = azurerm_firewall_policy.fw_policy.id
  description = "Central Firewall Policy ID"
}

output "waf_id_primary" {
  value       = azurerm_web_application_firewall_policy.waf_primary.id
  description = "Primary WAF Policy ID for Application Gateway"
}

output "waf_id_secondary" {
  value       = length(azurerm_web_application_firewall_policy.waf_secondary) > 0 ? azurerm_web_application_firewall_policy.waf_secondary[0].id : null
  description = "Secondary WAF Policy ID for Application Gateway (DR)"
}

output "fd_waf_id" {
  value       = azurerm_cdn_frontdoor_firewall_policy.fd_waf.id
  description = "Global Front Door WAF Policy ID"
}

output "storage_account_name" {
  value       = azurerm_storage_account.shared_sa.name
  description = "Shared Storage Account Name"
}

output "storage_account_key" {
  value       = azurerm_storage_account.shared_sa.primary_access_key
  sensitive   = true
  description = "Shared Storage Account Access Key"
}

output "mysql_dns_zone_id" {
  value       = azurerm_private_dns_zone.mysql_dns.id
  description = "MySQL Private DNS Zone Resource ID"
}

output "mysql_dns_name" {
  value       = azurerm_private_dns_zone.mysql_dns.name
  description = "MySQL Private DNS Zone Domain Name"
}

output "redis_dns_zone_id" {
  value       = azurerm_private_dns_zone.redis_dns.id
  description = "Redis Private DNS Zone Resource ID"
}

output "dcr_id" {
  value       = azurerm_monitor_data_collection_rule.linux_security_dcr.id
  description = "Data Collection Rule ID for AMA"
}

output "storage_endpoint" {
  value       = azurerm_storage_account.shared_sa.primary_blob_endpoint
  description = "Primary Storage Blob Endpoint for Boot Diagnostics"
}

output "secondary_storage_endpoint" {
  value       = length(azurerm_storage_account.secondary_sa) > 0 ? azurerm_storage_account.secondary_sa[0].primary_blob_endpoint : null
  description = "Secondary Storage Blob Endpoint for Boot Diagnostics"
}