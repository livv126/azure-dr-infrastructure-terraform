resource "azurerm_virtual_network" "dmz_vnet" {
  name                = "${var.prefix}-${var.geo}-vnet-dmz"
  location            = var.location
  resource_group_name = var.rgname
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "snet_agw" {
  name                 = "${var.prefix}-${var.geo}-snet-agw"
  resource_group_name  = var.rgname
  virtual_network_name = azurerm_virtual_network.dmz_vnet.name
  address_prefixes     = [cidrsubnet(var.vnet_cidr, 8, 1)]
}

resource "azurerm_public_ip" "pip_agw" {
  name                = "${var.prefix}-${var.geo}-agw-pip"
  location            = var.location
  resource_group_name = var.rgname
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_route_table" "dmz_rt" {
  name                = "${var.prefix}-${var.geo}-rt-dmz"
  location            = var.location
  resource_group_name = var.rgname
}

resource "azurerm_route" "dmz_to_app" {
  name                   = "to-app-vnet"
  resource_group_name    = var.rgname
  route_table_name       = azurerm_route_table.dmz_rt.name
  address_prefix         = var.app_vnet_cidr
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.hub_fw_private_ip
}

resource "azurerm_subnet_route_table_association" "dmz_assoc" {
  subnet_id      = azurerm_subnet.snet_agw.id
  route_table_id = azurerm_route_table.dmz_rt.id
}