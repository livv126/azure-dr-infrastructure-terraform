# ==========================================
# Primary Region Peering (Hub-Spoke)
# ==========================================
resource "azurerm_virtual_network_peering" "hub_to_dmz_primary" {
  name                         = "peer-hub-to-dmz-primary"
  resource_group_name          = var.rgname
  virtual_network_name         = module.hub_primary.vnet_name
  remote_virtual_network_id    = module.dmz_primary.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "dmz_to_hub_primary" {
  name                         = "peer-dmz-to-hub-primary"
  resource_group_name          = var.rgname
  virtual_network_name         = module.dmz_primary.vnet_name
  remote_virtual_network_id    = module.hub_primary.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "hub_to_app_primary" {
  name                         = "peer-hub-to-app-primary"
  resource_group_name          = var.rgname
  virtual_network_name         = module.hub_primary.vnet_name
  remote_virtual_network_id    = module.app_primary.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "app_to_hub_primary" {
  name                         = "peer-app-to-hub-primary"
  resource_group_name          = var.rgname
  virtual_network_name         = module.app_primary.vnet_name
  remote_virtual_network_id    = module.hub_primary.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "hub_to_data_primary" {
  name                         = "peer-hub-to-data-primary"
  resource_group_name          = var.rgname
  virtual_network_name         = module.hub_primary.vnet_name
  remote_virtual_network_id    = module.data_primary.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "data_to_hub_primary" {
  name                         = "peer-data-to-hub-primary"
  resource_group_name          = var.rgname
  virtual_network_name         = module.data_primary.vnet_name
  remote_virtual_network_id    = module.hub_primary.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# ==========================================
# Secondary Region Peering (Hub-Spoke)
# ==========================================
resource "azurerm_virtual_network_peering" "hub_to_dmz_secondary" {
  provider                     = azurerm.secondary
  name                         = "peer-hub-to-dmz-secondary"
  resource_group_name          = var.rgname
  virtual_network_name         = module.hub_secondary.vnet_name
  remote_virtual_network_id    = module.dmz_secondary.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "dmz_to_hub_secondary" {
  provider                     = azurerm.secondary
  name                         = "peer-dmz-to-hub-secondary"
  resource_group_name          = var.rgname
  virtual_network_name         = module.dmz_secondary.vnet_name
  remote_virtual_network_id    = module.hub_secondary.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "hub_to_app_secondary" {
  provider                     = azurerm.secondary
  name                         = "peer-hub-to-app-secondary"
  resource_group_name          = var.rgname
  virtual_network_name         = module.hub_secondary.vnet_name
  remote_virtual_network_id    = module.app_secondary.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "app_to_hub_secondary" {
  provider                     = azurerm.secondary
  name                         = "peer-app-to-hub-secondary"
  resource_group_name          = var.rgname
  virtual_network_name         = module.app_secondary.vnet_name
  remote_virtual_network_id    = module.hub_secondary.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "hub_to_data_secondary" {
  provider                     = azurerm.secondary
  name                         = "peer-hub-to-data-secondary"
  resource_group_name          = var.rgname
  virtual_network_name         = module.hub_secondary.vnet_name
  remote_virtual_network_id    = module.data_secondary.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "data_to_hub_secondary" {
  provider                     = azurerm.secondary
  name                         = "peer-data-to-hub-secondary"
  resource_group_name          = var.rgname
  virtual_network_name         = module.data_secondary.vnet_name
  remote_virtual_network_id    = module.hub_secondary.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# ==========================================
# Cross-Region Global Peering (Hub to Hub)
# ==========================================
resource "azurerm_virtual_network_peering" "peer_primary_to_secondary" {
  name                         = "peer-hub-primary-to-secondary"
  resource_group_name          = var.rgname
  virtual_network_name         = module.hub_primary.vnet_name
  remote_virtual_network_id    = module.hub_secondary.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "peer_secondary_to_primary" {
  provider                     = azurerm.secondary
  name                         = "peer-hub-secondary-to-primary"
  resource_group_name          = var.rgname
  virtual_network_name         = module.hub_secondary.vnet_name
  remote_virtual_network_id    = module.hub_primary.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# DNS Link for Cross-Region Redis resolution
resource "azurerm_private_dns_zone_virtual_network_link" "link_redis_secondary_hub" {
  provider              = azurerm.secondary
  name                  = "link-redis-secondary-hub"
  resource_group_name   = var.rgname
  private_dns_zone_name = "privatelink.redis.cache.windows.net"
  virtual_network_id    = module.hub_secondary.vnet_id
  depends_on            = [module.data_primary]
}