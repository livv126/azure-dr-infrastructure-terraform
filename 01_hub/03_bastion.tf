resource "azurerm_bastion_host" "hub_bastion" {
  name                = "${var.prefix}-${var.geo}-bastion"
  location            = var.location
  resource_group_name = var.rgname

  ip_configuration {
    name                 = "${var.prefix}-${var.geo}-configuration"
    subnet_id            = azurerm_subnet.hub_bat_snet.id
    public_ip_address_id = azurerm_public_ip.hub_bat_pubip.id
  }
}