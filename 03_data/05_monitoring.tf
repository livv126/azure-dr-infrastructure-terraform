resource "azurerm_monitor_diagnostic_setting" "mysql_diag" {
  name                       = "${var.geo}-mysql-audit-logs-${random_string.data_diag_suffix.result}"
  target_resource_id         = azurerm_mysql_flexible_server.mysql.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category = "MySqlSlowLogs" }
  enabled_log { category = "MySqlAuditLogs" }
  enabled_metric { category = "AllMetrics" }
  
  depends_on = [azurerm_mysql_flexible_server.mysql]
}

resource "azurerm_monitor_diagnostic_setting" "redis_diag" {
  count                      = var.enable_redis ? 1 : 0
  name                       = "${var.geo}-redis-audit-logs-${random_string.data_diag_suffix.result}"
  target_resource_id         = azurerm_redis_cache.redis[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric { category = "AllMetrics" }
  
  depends_on = [azurerm_redis_cache.redis]
}