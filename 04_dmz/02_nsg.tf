resource "azurerm_network_security_group" "nsg_agw" {
  name                = "${var.prefix}-${var.geo}-nsg-agw"
  location            = var.location
  resource_group_name = var.rgname
}

resource "azurerm_subnet_network_security_group_association" "agw_nsg_assoc" {
  subnet_id                 = azurerm_subnet.snet_agw.id
  network_security_group_id = azurerm_network_security_group.nsg_agw.id
}

resource "azurerm_network_security_rule" "allow_internet_http" {
  name                        = "Allow-Internet-HTTP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "AzureFrontDoor.Backend"
  destination_address_prefix  = "*"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_agw.name
}

resource "azurerm_network_security_rule" "allow_gw_manager" {
  name                        = "Allow-GatewayManager"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "65200-65535"
  source_address_prefix       = "GatewayManager"
  destination_address_prefix  = "*"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_agw.name
}

resource "azurerm_network_security_rule" "allow_azure_lb" {
  name                        = "Allow-AzureLoadBalancer"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = var.rgname
  network_security_group_name = azurerm_network_security_group.nsg_agw.name
}