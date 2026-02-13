resource "azurerm_virtual_network" "data_vnet" {
  name                = "${var.prefix}-${var.geo}-vnet-data"
  location            = var.location
  resource_group_name = var.rgname
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "db_snet" {
  name                 = "snet-db"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.data_vnet.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 1)]

  delegation {
    name = "fs-delegation"
    service_delegation {
      name    = "Microsoft.DBforMySQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "redis_snet" {
  name                 = "snet-redis"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.data_vnet.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 2)]

  private_endpoint_network_policies = "Enabled"
}

# DNS Links
resource "azurerm_private_dns_zone_virtual_network_link" "link_data" {
  name                  = "${var.prefix}-${var.geo}-link-data"
  resource_group_name   = var.rgname
  private_dns_zone_name = element(split("/", var.private_dns_zone_id), 8)
  virtual_network_id    = azurerm_virtual_network.data_vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "link_hub" {
  name                  = "${var.prefix}-${var.geo}-link-hub"
  resource_group_name   = var.rgname
  private_dns_zone_name = element(split("/", var.private_dns_zone_id), 8)
  virtual_network_id    = var.hub_vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis_link_data" {
  count                 = var.enable_redis ? 1 : 0
  name                  = "${var.prefix}-${var.geo}-redis-link-data"
  resource_group_name   = var.rgname
  private_dns_zone_name = "privatelink.redis.cache.windows.net"
  virtual_network_id    = azurerm_virtual_network.data_vnet.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis_link_hub" {
  count                 = var.enable_redis ? 1 : 0
  name                  = "${var.prefix}-${var.geo}-redis-link-hub"
  resource_group_name   = var.rgname
  private_dns_zone_name = "privatelink.redis.cache.windows.net"
  virtual_network_id    = var.hub_vnet_id
}

# Routing
resource "azurerm_route_table" "data_rt" {
  name                = "${var.prefix}-${var.geo}-rt"
  location            = var.location
  resource_group_name = var.rgname
}

resource "azurerm_route" "data_to_app" {
  name                   = "to-app-via-fw"
  resource_group_name    = var.rgname
  route_table_name       = azurerm_route_table.data_rt.name
  address_prefix         = var.app_vnet_cidr
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.hub_fw_private_ip
}

resource "azurerm_route" "data_to_internet" {
  name                   = "to-internet-via-fw"
  resource_group_name    = var.rgname
  route_table_name       = azurerm_route_table.data_rt.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.hub_fw_private_ip
}

resource "azurerm_route" "data_to_peer_app" {
  count                  = var.peer_app_vnet_cidr != null ? 1 : 0
  name                   = "to-peer-app-direct"
  resource_group_name    = var.rgname
  route_table_name       = azurerm_route_table.data_rt.name
  address_prefix         = var.peer_app_vnet_cidr
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.hub_fw_private_ip
}

resource "azurerm_subnet_route_table_association" "data_assoc" {
  subnet_id      = azurerm_subnet.db_snet.id
  route_table_id = azurerm_route_table.data_rt.id
}

resource "azurerm_subnet_route_table_association" "redis_assoc" {
  subnet_id      = azurerm_subnet.redis_snet.id
  route_table_id = azurerm_route_table.data_rt.id
}