terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      configuration_aliases = [azurerm.secondary]
    }
  }
}

variable "rgname" {
  type        = string
  description = "Target Resource Group Name"
}

variable "location" {
  type        = string
  description = "Primary region location"
}

variable "prefix" {
  type        = string
  description = "Resource name prefix"
}

variable "secondary_location" {
  type        = string
  description = "Secondary region location for DR configuration (Null to skip)"
  default     = null
}

variable "username" {
  type        = string
  description = "Default system administrator username"
}

variable "hub_primary_cidr" { type = string }
variable "dmz_primary_cidr" { type = string }
variable "app_primary_cidr" { type = string }
variable "data_primary_cidr" { type = string }

variable "hub_secondary_cidr" { type = string }
variable "app_secondary_cidr" { type = string }
variable "data_secondary_cidr" { type = string }
variable "dmz_secondary_cidr" { type = string }

variable "waf_mode" {
  type        = string
  default     = "Prevention"
  description = "WAF operation mode (Prevention or Detection)"
}

variable "waf_rule_set_type" {
  type        = string
  default     = "OWASP"
  description = "WAF managed rule set type"
}

variable "waf_rule_set_version" {
  type        = string
  default     = "3.2"
  description = "WAF managed rule set version"
}

resource "random_string" "common" {
  length  = 4
  special = false
  upper   = false
  numeric = true
}