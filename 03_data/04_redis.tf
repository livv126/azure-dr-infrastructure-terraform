resource "azurerm_redis_cache" "redis" {
  count                = var.enable_redis ? 1 : 0
  name                 = "${var.prefix}-${var.geo}-redis-cache"
  location             = var.location
  resource_group_name  = var.rgname
  capacity             = 1
  family               = "C"
  sku_name             = "Standard"
  non_ssl_port_enabled = false
  minimum_tls_version  = "1.2"

  redis_configuration {
    active_directory_authentication_enabled = true
    maxmemory_policy                        = "allkeys-lru"
    maxmemory_reserved                      = 50
    maxmemory_delta                         = 50
  }
}

resource "azurerm_private_endpoint" "redis_pe" {
  count               = var.enable_redis ? 1 : 0
  name                = "${var.prefix}-${var.geo}-redis-pe"
  location            = var.location
  resource_group_name = var.rgname
  subnet_id           = azurerm_subnet.redis_snet.id

  private_service_connection {
    name                           = "${var.prefix}-${var.geo}-redis-privconn"
    private_connection_resource_id = azurerm_redis_cache.redis[0].id
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }

  private_dns_zone_group {
    name                 = "redis-dns-group"
    private_dns_zone_ids = [var.redis_dns_zone_id]
  }
}