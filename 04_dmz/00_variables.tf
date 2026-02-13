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
  description = "DMZ VNet CIDR Block"
}
variable "hub_fw_private_ip" {
  type        = string
  description = "Hub Firewall Private IP for internal traffic routing"
}
variable "app_vnet_cidr" {
  type        = string
  description = "App VNet CIDR for routing target"
}
variable "lb_private_ip" {
  type        = string
  description = "App Internal Load Balancer (ILB) IP for backend pool"
}
variable "app_domain" {
  type        = string
  description = "Application custom domain for HTTP Host header and probes"
}
variable "waf_policy_id" {
  type        = string
  description = "WAF Policy ID to attach to Application Gateway"
}
variable "log_analytics_workspace_id" {
  type        = string
  description = "Workspace ID for App Gateway logging"
}

resource "random_string" "dmz_diag_suffix" {
  length  = 5
  special = false
  upper   = false
}