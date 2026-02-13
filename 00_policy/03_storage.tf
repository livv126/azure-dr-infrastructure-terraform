resource "random_string" "st_suffix" {
  length  = 4
  special = false
  upper   = false
}

# Primary Shared Storage
resource "azurerm_storage_account" "shared_sa" {
  name                     = "globalstorage${random_string.st_suffix.result}"
  resource_group_name      = var.rgname
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Secondary Storage for DR Boot Diagnostics
resource "azurerm_storage_account" "secondary_sa" {
  count                    = var.secondary_location != null ? 1 : 0
  name                     = "drstorage${random_string.st_suffix.result}"
  resource_group_name      = var.rgname
  location                 = var.secondary_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "boot_logs" {
  name                  = "boot-diagnostics"
  storage_account_id    = azurerm_storage_account.shared_sa.id
  container_access_type = "private"
}

# Store Shared Storage Keys in Key Vault
resource "azurerm_key_vault_secret" "storage_key" {
  name         = "global-storage-key-${random_string.common.result}"
  value        = azurerm_storage_account.shared_sa.primary_access_key
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault.kv]
}

resource "azurerm_key_vault_secret" "storage_name" {
  name         = "global-storage-name-${random_string.common.result}"
  value        = azurerm_storage_account.shared_sa.name
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault.kv]
}