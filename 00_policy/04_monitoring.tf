# Central Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.prefix}-law-security-${random_string.common.result}"
  location            = var.location
  resource_group_name = var.rgname
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# Microsoft Sentinel Onboarding
resource "azurerm_sentinel_log_analytics_workspace_onboarding" "sentinel" {
  workspace_id = azurerm_log_analytics_workspace.law.id
}

# Key Vault Diagnostics
resource "azurerm_monitor_diagnostic_setting" "kv_diag" {
  name                       = "kv-audit-logs-${random_string.common.result}"
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "AuditEvent"
  }
}

# Data Collection Rule for Linux Security Logs (Syslog)
resource "azurerm_monitor_data_collection_rule" "linux_security_dcr" {
  name                = "${var.prefix}-dcr-linux-security"
  resource_group_name = var.rgname
  location            = var.location

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.law.id
      name                  = "sentinel-workspace"
    }
  }
  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["sentinel-workspace"]
  }
  data_sources {
    syslog {
      facility_names = ["auth", "authpriv", "syslog", "cron"]
      log_levels     = ["Notice", "Warning", "Error", "Critical", "Alert", "Emergency"]
      name           = "security-syslogs"
      streams        = ["Microsoft-Syslog"]
    }
  }
}