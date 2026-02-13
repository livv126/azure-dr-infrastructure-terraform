terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

variable "rgname" { type = string }
variable "location" { type = string }
variable "prefix" {
  type        = string
  description = "Global resource naming prefix"
}
variable "geo" {
  type        = string
  description = "Regional identifier (e.g., primary, secondary)"
}

variable "vnet_cidr" {
  type        = string
  description = "App VNet CIDR Block"
}
variable "lb_private_ip" {
  type        = string
  description = "Static internal IP for Load Balancer"
}
variable "hub_fw_private_ip" {
  type        = string
  description = "Hub Firewall Private IP for traffic routing"
}

variable "hub_vnet_cidr" {
  type        = string
  description = "Hub VNet CIDR for SSH access rule"
}
variable "dmz_vnet_cidr" {
  type        = string
  description = "DMZ VNet CIDR for HTTP access rule"
}
variable "data_vnet_cidr" {
  type        = string
  description = "Data VNet CIDR for DB traffic routing"
}
variable "peer_data_vnet_cidr" {
  type        = string
  description = "Cross-region Data VNet CIDR for DR configuration"
  default     = null
}

variable "vm_count" {
  type        = number
  default     = 2
  description = "Initial VM instances count"
}
variable "username" {
  type        = string
  description = "Web server admin username"
}
variable "ssh_public_key" {
  type        = string
  description = "Web server SSH public key"
}

variable "domain_name" {
  type        = string
  description = "Application custom domain"
}
variable "db_host" {
  type        = string
  description = "Database FQDN"
}
variable "db_username" {
  type        = string
  description = "Database username"
}
variable "db_password" {
  type        = string
  sensitive   = true
  description = "Database password"
}

variable "storage_account_name" {
  type        = string
  description = "Shared storage account name for content"
}
variable "storage_account_key" {
  type        = string
  sensitive   = true
  description = "Shared storage account access key"
}

variable "redis_host" {
  type        = string
  description = "Redis Cache hostname"
}
variable "redis_key" {
  type        = string
  sensitive   = true
  description = "Redis Cache access key"
}

variable "dns_zone_name" {
  type        = string
  description = "Private DNS Zone name for Private Link"
}
variable "log_analytics_workspace_id" {
  type        = string
  description = "Workspace ID for logging"
}
variable "dcr_id" {
  type        = string
  description = "Data Collection Rule ID"
}
variable "repo_url" {
  type        = string
  description = "OS Package repository URL"
}
variable "boot_diag_uri" {
  type        = string
  description = "Storage URI for boot diagnostics"
}

resource "random_string" "app_diag_suffix" {
  length  = 5
  special = false
  upper   = false
}