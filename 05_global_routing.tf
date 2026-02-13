resource "azurerm_cdn_frontdoor_profile" "fd" {
  name                     = "${var.prefix}-fd-profile"
  resource_group_name      = azurerm_resource_group.team02_rg.name
  sku_name                 = "Standard_AzureFrontDoor"
  response_timeout_seconds = 60
}

resource "azurerm_cdn_frontdoor_endpoint" "fd_ep" {
  name                     = "${var.prefix}-frontend-ep-livv126"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id
}

resource "azurerm_cdn_frontdoor_origin_group" "fd_og" {
  name                     = "og-app-gateways"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id

  health_probe {
    path                = "/health.html"
    protocol            = "Http"
    request_type        = "HEAD"
    interval_in_seconds = 30
  }

  load_balancing {
    sample_size                        = 4
    successful_samples_required        = 3
    additional_latency_in_milliseconds = 50
  }
}

resource "azurerm_cdn_frontdoor_origin" "origin_primary" {
  name                           = "origin-appgw-primary"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fd_og.id
  enabled                        = true
  certificate_name_check_enabled = false
  host_name                      = module.dmz_primary.appgw_public_ip
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = "www.${var.app_domain}"
  priority                       = 1
  weight                         = 1000
}

resource "azurerm_cdn_frontdoor_origin" "origin_secondary" {
  name                           = "origin-appgw-secondary"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.fd_og.id
  enabled                        = true
  certificate_name_check_enabled = false
  host_name                      = module.dmz_secondary.appgw_public_ip
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = "www.${var.app_domain}"
  priority                       = 1
  weight                         = 1000
}

resource "azurerm_cdn_frontdoor_custom_domain" "fd_custom_domain" {
  name                     = "custom-domain-livv126"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id
  host_name                = "www.${var.app_domain}"
  tls { certificate_type = "ManagedCertificate" }
}

resource "azurerm_cdn_frontdoor_custom_domain" "fd_custom_domain_root" {
  name                     = "custom-domain-root"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id
  host_name                = var.app_domain
  tls { certificate_type = "ManagedCertificate" }
}

resource "azurerm_cdn_frontdoor_route" "fd_route" {
  name                          = "route-to-app"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fd_ep.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fd_og.id
  cdn_frontdoor_origin_ids      = [
    azurerm_cdn_frontdoor_origin.origin_primary.id,
    azurerm_cdn_frontdoor_origin.origin_secondary.id
  ]
  supported_protocols             = ["Http", "Https"]
  patterns_to_match               = ["/*"]
  forwarding_protocol             = "HttpOnly"
  link_to_default_domain          = true
  cdn_frontdoor_custom_domain_ids = [
    azurerm_cdn_frontdoor_custom_domain.fd_custom_domain.id,
    azurerm_cdn_frontdoor_custom_domain.fd_custom_domain_root.id
  ]
  https_redirect_enabled          = true
}

resource "azurerm_cdn_frontdoor_security_policy" "fd_sec_policy" {
  name                     = "${var.prefix}-sec-policy"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id
  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = module.policy.fd_waf_id
      association {
        domain { cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.fd_ep.id }
        domain { cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.fd_custom_domain.id }
        domain { cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_custom_domain.fd_custom_domain_root.id }
        patterns_to_match = ["/*"]
      }
    }
  }
}