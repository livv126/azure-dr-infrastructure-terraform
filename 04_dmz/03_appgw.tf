resource "azurerm_application_gateway" "agw_waf" {
  name                = "${var.prefix}-${var.geo}-agw-waf"
  resource_group_name = var.rgname
  location            = var.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-config"
    subnet_id = azurerm_subnet.snet_agw.id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "my-frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.pip_agw.id
  }

  probe {
    name                = "app-health-probe"
    protocol            = "Http"
    path                = "/health.html"
    host                = "www.${var.app_domain}"
    interval            = 10
    timeout             = 10
    unhealthy_threshold = 3

    match {
      status_code = ["200-399"]
    }
  }

  firewall_policy_id = var.waf_policy_id

  backend_address_pool {
    name         = "backend-pool"
    ip_addresses = [var.lb_private_ip]
  }

  backend_http_settings {
    name                                = "http-settings"
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 60
    probe_name                          = "app-health-probe"
    pick_host_name_from_backend_address = false
    host_name                           = "www.${var.app_domain}"
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "my-frontend-ip-config"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule-1"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "http-settings"
    priority                   = 1
  }
}