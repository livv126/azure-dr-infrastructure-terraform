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
variable "geo" {
  type        = string
  description = "Regional identifier (e.g., primary, secondary)"
}
variable "vnet_cidr" { type = string }
variable "username" { type = string }
variable "ssh_public_key" { type = string }
variable "ssh_private_key" {
  type      = string
  sensitive = true
}
variable "firewall_policy_id" { type = string }
variable "log_analytics_workspace_id" { type = string }
variable "dcr_id" { type = string }
variable "repo_url" { type = string }
variable "boot_diag_uri" { type = string }
variable "peer_hub_fw_ip" {
  type    = string
  default = null
}
variable "peer_spoke_cidr" {
  type    = string
  default = null
}

resource "random_string" "hub_diag_suffix" {
  length  = 5
  special = false
  upper   = false
}