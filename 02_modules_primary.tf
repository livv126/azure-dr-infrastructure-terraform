module "policy" {
  providers = {
    azurerm           = azurerm
    azurerm.secondary = azurerm.secondary
  }
  source             = "./00_policy"
  rgname             = azurerm_resource_group.team02_rg.name
  location           = local.primary_region
  prefix             = "policy"
  username           = var.username
  secondary_location = local.secondary_region

  hub_primary_cidr  = local.hub_cidr_primary
  dmz_primary_cidr  = local.dmz_cidr_primary
  app_primary_cidr  = local.app_cidr_primary
  data_primary_cidr = local.data_cidr_primary

  hub_secondary_cidr  = local.hub_cidr_secondary
  app_secondary_cidr  = local.app_cidr_secondary
  data_secondary_cidr = local.data_cidr_secondary
  dmz_secondary_cidr  = local.dmz_cidr_secondary

  waf_mode             = "Prevention"
  waf_rule_set_version = "3.2"
  depends_on           = [azurerm_resource_group.team02_rg]
}

module "hub_primary" {
  source                     = "./01_hub"
  rgname                     = azurerm_resource_group.team02_rg.name
  location                   = local.primary_region
  prefix                     = "01-hub"
  geo                        = local.primary_geo
  vnet_cidr                  = local.hub_cidr_primary
  username                   = var.username
  ssh_public_key             = module.policy.ssh_public_key
  ssh_private_key            = module.policy.ssh_private_key
  firewall_policy_id         = module.policy.firewall_policy_id
  log_analytics_workspace_id = module.policy.log_analytics_id
  dcr_id                     = module.policy.dcr_id
  repo_url                   = "http://mirror.navercorp.com/rocky"
  boot_diag_uri              = module.policy.storage_endpoint
  peer_hub_fw_ip             = local.hub_fw_private_ip_secondary
  peer_spoke_cidr            = local.app_cidr_secondary
  depends_on                 = [azurerm_resource_group.team02_rg]
}

module "app_primary" {
  source                     = "./02_app"
  rgname                     = azurerm_resource_group.team02_rg.name
  location                   = local.primary_region
  prefix                     = "02-app"
  geo                        = local.primary_geo
  vnet_cidr                  = local.app_cidr_primary
  hub_vnet_cidr              = local.hub_cidr_primary
  dmz_vnet_cidr              = local.dmz_cidr_primary
  data_vnet_cidr             = local.data_cidr_primary
  lb_private_ip              = local.app_lb_private_ip_primary
  hub_fw_private_ip          = local.hub_fw_private_ip_primary
  db_host                    = module.data_primary.db_fqdn
  dns_zone_name              = module.policy.mysql_dns_name
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
  repo_url                   = "http://mirror.navercorp.com/rocky"
  boot_diag_uri              = module.policy.storage_endpoint
  depends_on                 = [azurerm_resource_group.team02_rg]
}

module "data_primary" {
  source                     = "./03_data"
  rgname                     = azurerm_resource_group.team02_rg.name
  location                   = local.primary_region
  prefix                     = "03-data"
  geo                        = local.primary_geo
  vnet_cidr                  = local.data_cidr_primary
  hub_vnet_id                = module.hub_primary.vnet_id
  hub_fw_private_ip          = local.hub_fw_private_ip_primary
  app_vnet_cidr              = local.app_cidr_primary
  private_dns_zone_id        = module.policy.mysql_dns_zone_id
  dns_zone_name              = local.mysql_dns_name
  db_username                = module.policy.db_username
  db_password                = module.policy.db_password
  log_analytics_workspace_id = module.policy.log_analytics_id
  enable_redis               = true
  redis_dns_zone_id          = module.policy.redis_dns_zone_id
  hub_vnet_cidr              = local.hub_cidr_primary
  peer_app_vnet_cidr         = local.app_cidr_secondary
}

module "dmz_primary" {
  source                     = "./04_dmz"
  rgname                     = azurerm_resource_group.team02_rg.name
  location                   = local.primary_region
  prefix                     = "04-dmz"
  geo                        = local.primary_geo
  vnet_cidr                  = local.dmz_cidr_primary
  waf_policy_id              = module.policy.waf_id_primary
  lb_private_ip              = local.app_lb_private_ip_primary
  hub_fw_private_ip          = local.hub_fw_private_ip_primary
  app_vnet_cidr              = local.app_cidr_primary
  app_domain                 = var.app_domain
  log_analytics_workspace_id = module.policy.log_analytics_id
  depends_on                 = [azurerm_resource_group.team02_rg]
}