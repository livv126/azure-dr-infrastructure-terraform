resource "azurerm_virtual_network" "app_vnet" {
  name                = "${var.prefix}-${var.geo}-app-vnet"
  resource_group_name = var.rgname
  location            = var.location
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "app_snet" {
  name                 = "${var.prefix}-${var.geo}-snet-app"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.app_vnet.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 1)]
}

resource "azurerm_route_table" "app_rt" {
  name                = "${var.prefix}-${var.geo}-rt-app"
  location            = var.location
  resource_group_name = var.rgname
}

resource "azurerm_route" "to_data" {
  name                   = "to-data-subnet"
  resource_group_name    = var.rgname
  route_table_name       = azurerm_route_table.app_rt.name
  address_prefix         = var.data_vnet_cidr
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.hub_fw_private_ip
}

resource "azurerm_route" "to_dmz" {
  name                   = "to-dmz-subnet"
  resource_group_name    = var.rgname
  route_table_name       = azurerm_route_table.app_rt.name
  address_prefix         = var.dmz_vnet_cidr
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.hub_fw_private_ip
}

resource "azurerm_route" "to_internet" {
  name                   = "to-internet-via-fw"
  resource_group_name    = var.rgname
  route_table_name       = azurerm_route_table.app_rt.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.hub_fw_private_ip
}

# Cross-Region DR Routing to Peer Data
resource "azurerm_route" "to_peer_data" {
  count                  = var.peer_data_vnet_cidr != null ? 1 : 0
  name                   = "to-peer-data-via-fw"
  resource_group_name    = var.rgname
  route_table_name       = azurerm_route_table.app_rt.name
  address_prefix         = var.peer_data_vnet_cidr
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.hub_fw_private_ip
}

resource "azurerm_subnet_route_table_association" "app_assoc" {
  subnet_id      = azurerm_subnet.app_snet.id
  route_table_id = azurerm_route_table.app_rt.id
}

# VNet Links for Private DNS
resource "azurerm_private_dns_zone_virtual_network_link" "link_app_self" {
  name                  = "${var.prefix}-${var.geo}-link-app-self"
  resource_group_name   = var.rgname
  private_dns_zone_name = var.dns_zone_name
  virtual_network_id    = azurerm_virtual_network.app_vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis_link_app" {
  name                  = "${var.prefix}-${var.geo}-redis-link-app"
  resource_group_name   = var.rgname
  private_dns_zone_name = "privatelink.redis.cache.windows.net"
  virtual_network_id    = azurerm_virtual_network.app_vnet.id
}