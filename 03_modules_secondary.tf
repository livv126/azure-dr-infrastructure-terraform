module "hub_secondary" {
  source = "./01_hub"
  providers = { azurerm = azurerm.secondary }

  rgname                     = azurerm_resource_group.team02_rg.name
  location                   = local.secondary_region
  prefix                     = "05-hub"
  geo                        = local.secondary_geo
  vnet_cidr                  = local.hub_cidr_secondary
  username                   = var.username
  ssh_public_key             = module.policy.ssh_public_key
  ssh_private_key            = module.policy.ssh_private_key
  firewall_policy_id         = module.policy.firewall_policy_id
  log_analytics_workspace_id = module.policy.log_analytics_id
  dcr_id                     = module.policy.dcr_id
  repo_url                   = "http://dl.rockylinux.org/pub/rocky"
  boot_diag_uri              = module.policy.secondary_storage_endpoint
  peer_hub_fw_ip             = local.hub_fw_private_ip_primary
  peer_spoke_cidr            = local.data_cidr_primary
  depends_on                 = [azurerm_resource_group.team02_rg]
}

module "app_secondary" {
  source = "./02_app"
  providers = { azurerm = azurerm.secondary }

  rgname                     = azurerm_resource_group.team02_rg.name
  location                   = local.secondary_region
  prefix                     = "06-app"
  geo                        = local.secondary_geo
  vnet_cidr                  = local.app_cidr_secondary
  lb_private_ip              = local.app_lb_private_ip_secondary
  hub_fw_private_ip          = local.hub_fw_private_ip_secondary
  hub_vnet_cidr              = local.hub_cidr_secondary
  dmz_vnet_cidr              = local.dmz_cidr_secondary
  data_vnet_cidr             = local.data_cidr_secondary
  db_host                    = module.data_primary.db_fqdn
  dns_zone_name              = module.data_secondary.dns_zone_name
  username                   = var.username
  ssh_public_key             = module.policy.ssh_public_key
  vm_count                   = 2
  db_username                = module.policy.db_username
  db_password                = module.policy.db_password
  storage_account_name       = module.policy.storage_account_name
  storage_account_key        = module.policy.storage_account_key
  domain_name                = var.app_domain
  log_analytics_workspace_id = module.policy.log_analytics_id
  dcr_id                     = module.policy.dcr_id
  redis_host                 = module.data_primary.redis_hostname
  redis_key                  = module.data_primary.redis_primary_key
  repo_url                   = "http://dl.rockylinux.org/pub/rocky"
  boot_diag_uri              = module.policy.secondary_storage_endpoint
  peer_data_vnet_cidr        = local.data_cidr_primary
  depends_on                 = [azurerm_resource_group.team02_rg]
}

module "data_secondary" {
  source = "./03_data"
  providers = { azurerm = azurerm.secondary }

  rgname                     = azurerm_resource_group.team02_rg.name
  location                   = local.secondary_region
  prefix                     = "07-data"
  geo                        = local.secondary_geo
  vnet_cidr                  = local.data_cidr_secondary
  hub_vnet_id                = module.hub_secondary.vnet_id
  hub_fw_private_ip          = local.hub_fw_private_ip_secondary
  app_vnet_cidr              = local.app_cidr_secondary
  dns_zone_name              = local.mysql_dns_name
  private_dns_zone_id        = module.policy.mysql_dns_zone_id
  db_username                = module.policy.db_username
  db_password                = module.policy.db_password
  log_analytics_workspace_id = module.policy.log_analytics_id
  create_mode                = "Replica"
  source_server_id           = module.data_primary.mysql_id
  enable_redis               = false
  redis_dns_zone_id          = module.policy.redis_dns_zone_id
  hub_vnet_cidr              = local.hub_cidr_secondary
  depends_on                 = [module.data_primary]
}

module "dmz_secondary" {
  source = "./04_dmz"
  providers = { azurerm = azurerm.secondary }

  rgname                     = azurerm_resource_group.team02_rg.name
  location                   = local.secondary_region
  prefix                     = "08-dmz"
  geo                        = local.secondary_geo
  vnet_cidr                  = local.dmz_cidr_secondary
  lb_private_ip              = local.app_lb_private_ip_secondary
  hub_fw_private_ip          = local.hub_fw_private_ip_secondary
  app_vnet_cidr              = local.app_cidr_secondary
  app_domain                 = var.app_domain
  waf_policy_id              = module.policy.waf_id_secondary
  log_analytics_workspace_id = module.policy.log_analytics_id
  depends_on                 = [azurerm_resource_group.team02_rg]
}