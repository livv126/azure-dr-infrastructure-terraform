resource "azurerm_monitor_diagnostic_setting" "fw_diag" {
  name                       = "${var.geo}-fw-traffic-logs-${random_string.hub_diag_suffix.result}"
  target_resource_id         = azurerm_firewall.hub_fw.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category = "AzureFirewallApplicationRule" }
  enabled_log { category = "AzureFirewallNetworkRule" }
  enabled_log { category = "AzureFirewallDnsProxy" }
  depends_on = [azurerm_firewall.hub_fw]
}

resource "azurerm_monitor_diagnostic_setting" "bastion_diag" {
  name                       = "${var.geo}-bastion-audit-${random_string.hub_diag_suffix.result}"
  target_resource_id         = azurerm_bastion_host.hub_bastion.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log { category = "BastionAuditLogs" }
  depends_on = [azurerm_bastion_host.hub_bastion]
}

resource "azurerm_virtual_machine_extension" "ama_linux_hub" {
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.hub_mgmtvm.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.25"
  auto_upgrade_minor_version = true
}

resource "azurerm_monitor_data_collection_rule_association" "hub_vm_dcr_assoc" {
  name                    = "${var.prefix}-${var.geo}-hub-vm-dcr-assoc"
  target_resource_id      = azurerm_linux_virtual_machine.hub_mgmtvm.id
  data_collection_rule_id = var.dcr_id
  depends_on              = [azurerm_virtual_machine_extension.ama_linux_hub]
}