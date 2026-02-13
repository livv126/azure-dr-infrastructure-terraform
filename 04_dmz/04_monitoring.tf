resource "azurerm_monitor_diagnostic_setting" "agw_diag" {
  name                       = "${var.geo}-agw-access-logs-${random_string.dmz_diag_suffix.result}"
  target_resource_id         = azurerm_application_gateway.agw_waf.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category = "ApplicationGatewayAccessLog" }
  enabled_log { category = "ApplicationGatewayPerformanceLog" }
  enabled_log { category = "ApplicationGatewayFirewallLog" }
  enabled_metric { category = "AllMetrics" }
}