output "GLOBAL_SERVICE_INFO" {
  value = {
    frontdoor_endpoint = azurerm_cdn_frontdoor_endpoint.fd_ep.host_name
    service_domain     = "https://${azurerm_cdn_frontdoor_custom_domain.fd_custom_domain.host_name}"
    private_dns_zone   = module.policy.mysql_dns_name
  }
  description = "Summary of Global Service Endpoints"
}

output "SHARED_RESOURCE_INFO" {
  value = {
    log_analytics_id     = module.policy.log_analytics_id
    storage_account_name = module.policy.storage_account_name
  }
  description = "Shared Resource Identifiers"
}

output "PRIMARY_REGION_DETAILS" {
  value = {
    frontend_public_ip = module.dmz_primary.appgw_public_ip
    bastion_public_ip  = module.hub_primary.bastion_public_ip
    firewall_ip        = module.hub_primary.fw_private_ip
    vmss_name          = module.app_primary.vmss_name
    ilb_private_ip     = module.app_primary.lb_private_ip
    db_address         = module.data_primary.db_fqdn
    redis_address      = module.data_primary.redis_hostname
    vnet_name          = module.hub_primary.vnet_name
  }
  description = "Core Connection Info for Primary Region"
}

output "SECONDARY_REGION_DETAILS" {
  value = {
    frontend_public_ip = module.dmz_secondary.appgw_public_ip
    bastion_public_ip  = module.hub_secondary.bastion_public_ip
    firewall_ip        = module.hub_secondary.fw_private_ip
    vmss_name          = module.app_secondary.vmss_name
    ilb_private_ip     = module.app_secondary.lb_private_ip
    db_address         = module.data_secondary.db_fqdn
    vnet_name          = module.hub_secondary.vnet_name
  }
  description = "Core Connection Info for Secondary (DR) Region"
}

output "ADMIN_ACCESS_COMMANDS" {
  value = <<EOT

  ================================================================================
  [1] Primary Region Access (Seoul)
  ================================================================================
  # Connect to Bastion Host
  ssh -i <path-to-key> ${var.username}@${module.hub_primary.bastion_public_ip}

  # Connect to Web Server via Bastion
  ssh -J ${var.username}@${module.hub_primary.bastion_public_ip} ${var.username}@<TARGET_PRIVATE_IP>

  ================================================================================
  [2] Secondary Region Access (Disaster Recovery)
  ================================================================================
  # Connect to Bastion Host
  ssh -i <path-to-key> ${var.username}@${module.hub_secondary.bastion_public_ip}

  # Connect to Web Server via Bastion
  ssh -J ${var.username}@${module.hub_secondary.bastion_public_ip} ${var.username}@<TARGET_PRIVATE_IP>
  ================================================================================
EOT
  description = "SSH Commands for Administrator Access"
}