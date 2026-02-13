variable "subscription_id" {
  type        = string
  default     = null
  sensitive   = true
  description = "Azure Subscription ID"
}

variable "rgname" {
  type        = string
  default     = "05-team02-rg"
  description = "Target Resource Group Name"
}

variable "username" {
  type        = string
  default     = "adminuser"
  description = "Common administrator username for VMs"
}

variable "app_domain" {
  type        = string
  default     = "livv126.store"
  description = "Application custom domain"
}

variable "prefix" {
  type        = string
  default     = "team02"
  description = "Global resource naming prefix"
}

locals {
  project = "team02"

  # Private DNS Zone Name Definition
  mysql_dns_name = "privatelink.mysql.database.azure.com"

  # Primary Region (e.g., Korea Central)
  primary_region = "koreacentral"
  primary_geo    = "primary"

  # Secondary Region for DR (e.g., Canada Central / Japan East)
  secondary_region = "canadacentral"
  secondary_geo    = "secondary"

  # Primary Network CIDRs
  hub_cidr_primary  = "10.10.0.0/16"
  app_cidr_primary  = "10.20.0.0/16"
  data_cidr_primary = "10.30.0.0/16"
  dmz_cidr_primary  = "10.40.0.0/16"
  data_subnet_cidr_primary = "10.30.1.0/24"

  # Secondary Network CIDRs (DR)
  hub_cidr_secondary  = "10.50.0.0/16"
  app_cidr_secondary  = "10.60.0.0/16"
  data_cidr_secondary = "10.70.0.0/16"
  dmz_cidr_secondary  = "10.80.0.0/16"
  data_subnet_cidr_secondary = "10.70.1.0/24"

  # Pre-calculated IPs for Internal Routing & Load Balancing
  hub_fw_private_ip_primary = cidrhost(cidrsubnet(local.hub_cidr_primary, 8, 2), 4)
  app_lb_private_ip_primary = cidrhost(cidrsubnet(local.app_cidr_primary, 8, 1), 4)

  hub_fw_private_ip_secondary = cidrhost(cidrsubnet(local.hub_cidr_secondary, 8, 2), 4)
  app_lb_private_ip_secondary = cidrhost(cidrsubnet(local.app_cidr_secondary, 8, 1), 4)
}

resource "azurerm_resource_group" "team02_rg" {
  name     = var.rgname
  location = local.primary_region
}