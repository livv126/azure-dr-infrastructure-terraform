resource "random_string" "global_diag_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_monitor_diagnostic_setting" "fd_diag" {
  name                       = "global-fd-security-logs-${random_string.global_diag_suffix.result}"
  target_resource_id         = azurerm_cdn_frontdoor_profile.fd.id
  log_analytics_workspace_id = module.policy.log_analytics_id

  enabled_log { category = "FrontDoorWebApplicationFirewallLog" }
  enabled_log { category = "FrontDoorAccessLog" }
  enabled_log { category = "FrontDoorHealthProbeLog" }
  enabled_metric { category = "AllMetrics" }

  depends_on = [azurerm_cdn_frontdoor_profile.fd]
}