resource "azurerm_virtual_network" "hub_vnet" {
  name                = "${var.prefix}-${var.geo}-hub-vnet"
  location            = var.location
  resource_group_name = var.rgname
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "hub_fw_snet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 2)]
}

resource "azurerm_subnet" "hub_bat_snet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 3)]
}

resource "azurerm_subnet" "hub_mgmt_snet" {
  name                 = "${var.prefix}-${var.geo}-snet-mgmt"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 4)]
}

resource "azurerm_public_ip" "hub_fw_pubip" {
  name                = "${var.prefix}-${var.geo}-fw-pubip"
  location            = var.location
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "hub_bat_pubip" {
  name                = "${var.prefix}-${var.geo}-bastion-pubip"
  location            = var.location
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_route_table" "mgmt_rt" {
  name                = "${var.prefix}-${var.geo}-mgmt-rt"
  location            = var.location
  resource_group_name = var.rgname
}

resource "azurerm_route" "mgmt_to_fw" {
  name                   = "${var.prefix}-${var.geo}-to-firewall"
  resource_group_name    = var.rgname
  route_table_name       = azurerm_route_table.mgmt_rt.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.hub_fw.ip_configuration[0].private_ip_address
}

resource "azurerm_subnet_route_table_association" "mgmt_rt_assoc" {
  subnet_id      = azurerm_subnet.hub_mgmt_snet.id
  route_table_id = azurerm_route_table.mgmt_rt.id
}

resource "azurerm_route_table" "fw_rt" {
  name                = "${var.prefix}-${var.geo}-fw-rt"
  location            = var.location
  resource_group_name = var.rgname
}

resource "azurerm_route" "fw_to_internet" {
  name                = "fw-to-internet"
  resource_group_name = var.rgname
  route_table_name    = azurerm_route_table.fw_rt.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
}

# Cross-Region DR Routing
resource "azurerm_route" "to_peer_spoke" {
  count                  = var.peer_hub_fw_ip != null && var.peer_spoke_cidr != null ? 1 : 0
  name                   = "to-peer-spoke-via-peer-fw"
  resource_group_name    = var.rgname
  route_table_name       = azurerm_route_table.fw_rt.name
  address_prefix         = var.peer_spoke_cidr
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.peer_hub_fw_ip
}

resource "azurerm_subnet_route_table_association" "fw_snet_assoc" {
  subnet_id      = azurerm_subnet.hub_fw_snet.id
  route_table_id = azurerm_route_table.fw_rt.id
  depends_on     = [azurerm_route.fw_to_internet, azurerm_route.to_peer_spoke]
}