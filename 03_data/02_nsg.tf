resource "azurerm_network_security_group" "db_nsg" {
  name                = "${var.prefix}-${var.geo}-nsg-db"
  location            = var.location
  resource_group_name = var.rgname
}

resource "azurerm_subnet_network_security_group_association" "db_nsg_assoc" {
  subnet_id                 = azurerm_subnet.db_snet.id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}

resource "azurerm_network_security_group" "redis_nsg" {
  name                = "${var.prefix}-${var.geo}-nsg-redis"
  location            = var.location
  resource_group_name = var.rgname
}

resource "azurerm_subnet_network_security_group_association" "redis_nsg_assoc" {
  subnet_id                 = azurerm_subnet.redis_snet.id
  network_security_group_id = azurerm_network_security_group.redis_nsg.id
}

# DB Security Rules
resource "azurerm_network_security_rule" "db_allow_app" {
  name                        = "Allow-MySQL-From-App"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3306"
  source_address_prefix       = var.app_vnet_cidr
  destination_address_prefix  = "*"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.db_nsg.name
}

resource "azurerm_network_security_rule" "db_allow_hub" {
  name                        = "Allow-MySQL-From-Hub"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3306"
  source_address_prefix       = var.hub_vnet_cidr
  destination_address_prefix  = "*"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.db_nsg.name
}

resource "azurerm_network_security_rule" "db_allow_peer_app" {
  count                       = var.peer_app_vnet_cidr != null ? 1 : 0
  name                        = "Allow-MySQL-From-Peer-App"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3306"
  source_address_prefix       = var.peer_app_vnet_cidr
  destination_address_prefix  = "*"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.db_nsg.name
}

# Redis Security Rules
resource "azurerm_network_security_rule" "redis_allow_app" {
  name                        = "Allow-Redis-From-App"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "6380"
  source_address_prefix       = var.app_vnet_cidr
  destination_address_prefix  = "*"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.redis_nsg.name
}

resource "azurerm_network_security_rule" "redis_allow_hub" {
  name                        = "Allow-Redis-From-Hub"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "6380"
  source_address_prefix       = var.hub_vnet_cidr
  destination_address_prefix  = "*"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.redis_nsg.name
}

resource "azurerm_network_security_rule" "redis_allow_peer_app" {
  count                       = var.peer_app_vnet_cidr != null && var.enable_redis ? 1 : 0
  name                        = "Allow-Redis-From-Peer-App"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "6380"
  source_address_prefix       = var.peer_app_vnet_cidr
  destination_address_prefix  = "*"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.redis_nsg.name
}