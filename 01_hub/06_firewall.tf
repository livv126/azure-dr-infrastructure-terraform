resource "azurerm_firewall" "hub_fw" {
  name                = "${var.prefix}-${var.geo}-firewall"
  location            = var.location
  resource_group_name = var.rgname
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = var.firewall_policy_id

  ip_configuration {
    name                 = "${var.prefix}-${var.geo}-firewall-config"
    subnet_id            = azurerm_subnet.hub_fw_snet.id
    public_ip_address_id = azurerm_public_ip.hub_fw_pubip.id
  }
}