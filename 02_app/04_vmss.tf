resource "azurerm_linux_virtual_machine_scale_set" "app_vmss" {
  name                            = "${var.prefix}-${var.geo}-vmss"
  resource_group_name             = var.rgname
  location                        = var.location
  sku                             = "Standard_B2s"
  instances                       = var.vm_count
  admin_username                  = var.username
  disable_password_authentication = true
  upgrade_mode                    = "Automatic"
  zones                           = ["1", "2", "3"]

  admin_ssh_key {
    username   = var.username
    public_key = var.ssh_public_key
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }

  source_image_reference {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "9-lvm"
    version   = "9.6.20250531"
  }

  plan {
    publisher = "resf"
    product   = "rockylinux-x86_64"
    name      = "9-lvm"
  }

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.app_snet.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.app_bep.id]
    }
  }

  user_data = base64encode(replace(templatefile("${path.module}/web_init.yaml", {
    db_host              = var.db_host
    db_username          = var.db_username
    db_password          = var.db_password
    storage_account_name = var.storage_account_name
    storage_account_key  = var.storage_account_key
    domain_name          = var.domain_name
    redis_host           = var.redis_host
    redis_key            = var.redis_key
    repo_url             = var.repo_url
  }), "\r", ""))

  boot_diagnostics {
    storage_account_uri = var.boot_diag_uri
  }
}

resource "azurerm_monitor_autoscale_setting" "vmss_autoscale" {
  name                = "${var.prefix}-${var.geo}-autoscale"
  resource_group_name = var.rgname
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.app_vmss.id

  profile {
    name = "defaultProfile"
    capacity {
      default = 2
      minimum = 2
      maximum = 5
    }
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.app_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 80
      }
      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.app_vmss.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 30
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }
}