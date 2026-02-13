terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

variable "rgname" { type = string }
variable "location" { type = string }
variable "prefix" { type = string }
variable "geo" { type = string }

variable "vnet_cidr" {
  type        = string
  description = "Data VNet CIDR block"
}
variable "hub_vnet_id" {
  type        = string
  description = "Hub VNet ID for Private DNS Zone linking"
}
variable "hub_fw_private_ip" {
  type        = string
  description = "Hub Firewall Private IP for traffic routing"
}
variable "app_vnet_cidr" {
  type        = string
  description = "App VNet CIDR for DB access rule"
}
variable "hub_vnet_cidr" {
  type        = string
  description = "Hub VNet CIDR for admin access rule"
}
variable "peer_app_vnet_cidr" {
  type        = string
  description = "Cross-region App VNet CIDR for DR configuration"
  default     = null
}

variable "db_username" {
  type        = string
  description = "MySQL administrator username"
}
variable "db_password" {
  type        = string
  sensitive   = true
  description = "MySQL administrator password"
}
variable "create_mode" {
  type        = string
  default     = "Default"
  description = "Database creation mode (Default for Primary, Replica for DR Secondary)"
}
variable "source_server_id" {
  type        = string
  default     = null
  description = "Source Master DB Resource ID (Required if create_mode is Replica)"
}

variable "enable_redis" {
  type        = bool
  default     = false
  description = "Flag to create Redis Cache (true for Primary, false for DR Secondary)"
}
variable "dns_zone_name" {
  type        = string
  description = "MySQL Private DNS Zone name"
}
variable "private_dns_zone_id" {
  type        = string
  description = "MySQL Private DNS Zone Resource ID"
}
variable "redis_dns_zone_id" {
  type        = string
  description = "Redis Private DNS Zone Resource ID"
}
variable "log_analytics_workspace_id" {
  type        = string
  description = "Workspace ID for DB and Redis diagnostic logging"
}

resource "random_string" "data_diag_suffix" {
  length  = 5
  special = false
  upper   = false
}