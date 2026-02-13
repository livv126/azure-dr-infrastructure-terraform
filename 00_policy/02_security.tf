data "azurerm_client_config" "current" {}

# Core Key Vault
resource "azurerm_key_vault" "kv" {
  name                        = "${var.prefix}-kv-core-${random_string.common.result}"
  location                    = var.location
  resource_group_name         = var.rgname
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"

  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = data.azurerm_client_config.current.object_id
    secret_permissions = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
  }
}

# SSH Key Pair Generation
resource "tls_private_key" "global_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "ssh-key-private-${random_string.common.result}"
  value        = tls_private_key.global_key.private_key_pem
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "application/x-pem-file"
  depends_on   = [azurerm_key_vault.kv]
}

resource "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "ssh-key-public-${random_string.common.result}"
  value        = tls_private_key.global_key.public_key_openssh
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault.kv]
}

# DB Credentials
resource "random_password" "db_pass" {
  length  = 16
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "azurerm_key_vault_secret" "db_user" {
  name         = "db-username-${random_string.common.result}"
  value        = var.username
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault.kv]
}

resource "azurerm_key_vault_secret" "db_pass" {
  name         = "db-password-${random_string.common.result}"
  value        = random_password.db_pass.result
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault.kv]
}

# Centralized Firewall Policy
resource "azurerm_firewall_policy" "fw_policy" {
  name                     = "${var.prefix}-afp-core"
  resource_group_name      = var.rgname
  location                 = var.location
  sku                      = "Standard"
  threat_intelligence_mode = "Alert"
}

resource "azurerm_firewall_policy_rule_collection_group" "prod_rules" {
  name               = "${var.prefix}-rcg-prod"
  firewall_policy_id = azurerm_firewall_policy.fw_policy.id
  priority           = 100

  network_rule_collection {
    name     = "core-network-rules"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "allow-dmz-to-app"
      protocols             = ["TCP"]
      source_addresses      = [var.dmz_primary_cidr, var.dmz_secondary_cidr]
      destination_addresses = [var.app_primary_cidr, var.app_secondary_cidr]
      destination_ports     = ["80"]
    }
    rule {
      name                  = "allow-app-to-db"
      protocols             = ["TCP"]
      source_addresses      = [var.app_primary_cidr, var.app_secondary_cidr]
      destination_addresses = [var.data_primary_cidr, var.data_secondary_cidr]
      destination_ports     = ["3306"]
    }
    rule {
      name                  = "allow-dns"
      protocols             = ["UDP"]
      source_addresses      = [
        var.hub_primary_cidr, var.dmz_primary_cidr, var.app_primary_cidr, var.data_primary_cidr,
        var.hub_secondary_cidr, var.app_secondary_cidr, var.data_secondary_cidr, var.dmz_secondary_cidr
      ]
      destination_addresses = ["1.1.1.1", "8.8.8.8"]
      destination_ports     = ["53"]
    }
    rule {
      name                  = "allow-app-to-redis"
      protocols             = ["TCP"]
      source_addresses      = [var.app_primary_cidr, var.app_secondary_cidr]
      destination_addresses = [var.data_primary_cidr, var.data_secondary_cidr]
      destination_ports     = ["6380"]
    }
  }

  application_rule_collection {
    name     = "app-allow-updates"
    priority = 200
    action   = "Allow"

    rule {
      name = "allow-linux-repo"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = [var.hub_primary_cidr, var.app_primary_cidr, var.hub_secondary_cidr, var.app_secondary_cidr]
      destination_fqdns = ["*.rockylinux.org", "*.fedoraproject.org", "dl.fedoraproject.org", "mirrors.rockylinux.org", "dl.rockylinux.org", "pub.rockylinux.org", "packages.microsoft.com"]
    }
    rule {
      name = "allow-wordpress-github"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = [var.app_primary_cidr, var.app_secondary_cidr]
      destination_fqdns = ["*.wordpress.org", "*.github.com", "github.com", "*.githubusercontent.com"]
    }
    rule {
      name = "allow-rocky-naver-mirror"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = [var.hub_primary_cidr, var.app_primary_cidr]
      destination_fqdns = ["mirror.navercorp.com", "*.navercorp.com"]
    }
  }
}

# WAF Policy - Primary
resource "azurerm_web_application_firewall_policy" "waf_primary" {
  name                = "${var.prefix}-waf-primary"
  resource_group_name = var.rgname
  location            = var.location

  policy_settings {
    enabled                     = true
    mode                        = var.waf_mode
    request_body_check          = true
    max_request_body_size_in_kb = 128
    file_upload_limit_in_mb     = 100
  }
  managed_rules {
    managed_rule_set {
      type    = var.waf_rule_set_type
      version = var.waf_rule_set_version
    }
  }
}

# WAF Policy - Secondary (DR)
resource "azurerm_web_application_firewall_policy" "waf_secondary" {
  provider            = azurerm.secondary
  count               = var.secondary_location != null ? 1 : 0
  name                = "${var.prefix}-waf-secondary"
  resource_group_name = var.rgname
  location            = var.secondary_location

  policy_settings {
    enabled                     = true
    mode                        = var.waf_mode
    request_body_check          = true
    max_request_body_size_in_kb = 128
    file_upload_limit_in_mb     = 100
  }
  managed_rules {
    managed_rule_set {
      type    = var.waf_rule_set_type
      version = var.waf_rule_set_version
    }
  }
}

# Front Door Global WAF
resource "azurerm_cdn_frontdoor_firewall_policy" "fd_waf" {
  name                = "${var.prefix}fdwafglobal"
  resource_group_name = var.rgname
  sku_name            = "Standard_AzureFrontDoor"
  enabled             = true
  mode                = "Prevention"
}