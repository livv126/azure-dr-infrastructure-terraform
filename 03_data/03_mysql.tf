resource "azurerm_mysql_flexible_server" "mysql" {
  name                   = "${var.prefix}-${var.geo}-mysql"
  resource_group_name    = var.rgname
  location               = var.location
  administrator_login    = var.create_mode == "Default" ? var.db_username : null
  administrator_password = var.create_mode == "Default" ? var.db_password : null
  create_mode            = var.create_mode
  source_server_id       = var.create_mode == "Replica" ? var.source_server_id : null
  sku_name               = "GP_Standard_D2ds_v4"
  version                = "8.0.21"
  zone                   = "1"

  dynamic "high_availability" {
    for_each = var.create_mode == "Replica" ? [] : [1]
    content {
      mode                      = "ZoneRedundant"
      standby_availability_zone = "2"
    }
  }

  delegated_subnet_id          = azurerm_subnet.db_snet.id
  private_dns_zone_id          = var.private_dns_zone_id
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  
  depends_on = [azurerm_private_dns_zone_virtual_network_link.link_data]
}

resource "azurerm_mysql_flexible_database" "wp_db" {
  count               = var.create_mode == "Default" ? 1 : 0
  name                = "wordpress"
  resource_group_name = var.rgname
  server_name         = azurerm_mysql_flexible_server.mysql.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}

resource "azurerm_mysql_flexible_server_configuration" "no_ssl" {
  name                = "require_secure_transport"
  resource_group_name = var.rgname
  server_name         = azurerm_mysql_flexible_server.mysql.name
  value               = "OFF"
}