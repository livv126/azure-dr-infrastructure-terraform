resource "azurerm_lb" "app_lb" {
  name                = "${var.prefix}-${var.geo}-ilb"
  location            = var.location
  resource_group_name = var.rgname
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "LoadBalancerFrontEnd"
    subnet_id                     = azurerm_subnet.app_snet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.lb_private_ip
  }
}

resource "azurerm_lb_backend_address_pool" "app_bep" {
  loadbalancer_id = azurerm_lb.app_lb.id
  name            = "bep-web-vms"
}

resource "azurerm_lb_probe" "http_probe" {
  loadbalancer_id = azurerm_lb.app_lb.id
  name            = "http-probe"
  port            = 80
  protocol        = "Http"
  request_path    = "/health.html"
}

resource "azurerm_lb_rule" "rule_80" {
  loadbalancer_id                = azurerm_lb.app_lb.id
  name                           = "Http-Rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.app_bep.id]
  probe_id                       = azurerm_lb_probe.http_probe.id
}