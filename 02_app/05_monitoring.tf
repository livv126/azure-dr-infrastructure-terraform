resource "azurerm_monitor_diagnostic_setting" "lb_diag" {
  name                       = "${var.geo}-lb-health-logs-${random_string.app_diag_suffix.result}"
  target_resource_id         = azurerm_lb.app_lb.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
  depends_on = [azurerm_lb.app_lb]
}

resource "azurerm_virtual_machine_scale_set_extension" "ama_linux" {
  name                         = "AzureMonitorLinuxAgent"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.app_vmss.id
  publisher                    = "Microsoft.Azure.Monitor"
  type                         = "AzureMonitorLinuxAgent"
  type_handler_version         = "1.2"
  auto_upgrade_minor_version   = true
}

resource "azurerm_monitor_data_collection_rule_association" "vmss_dcr_assoc" {
  name                    = "${var.prefix}-${var.geo}-vmss-dcr-assoc"
  target_resource_id      = azurerm_linux_virtual_machine_scale_set.app_vmss.id
  data_collection_rule_id = var.dcr_id
  depends_on              = [azurerm_virtual_machine_scale_set_extension.ama_linux]
}