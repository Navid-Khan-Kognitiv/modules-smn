#########################################
# List of Default Variables
#########################################
variable "release_version" {
  type = string
}
variable "global_common_tags" {
  type = map(any)
}
variable "subscription_common_tags" {
  type = map(any)
}
variable "resource_group_common_tags" {
  type = map(any)
}
variable "environment_common_tags" {
  type = map(any)
}
variable "role_common_tags" {
  type = map(any)
}

################################
# Inputs for the Storage Account
################################
variable "client_name" {
  description = "Client name/account used in naming"
  type        = string
}

variable "name_prefix" {
  description = "Optional prefix for names"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Project environment"
  type        = string
}

variable "custom_storage_account_name" {
  description = "Optional custom name"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags shared by all resources of this module. Will be merged with any other specific tags by resource."
  default     = {}
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "The location in which the resources will be created."
  type        = string
}

variable "location_short" {
  description = "Short string for Azure location."
  type        = string
}

variable "access_tier" {
  description = "Access Tier for the Storage Account (Hot or Cool)"
  type        = string
  default     = "Hot"
}

variable "replication_type" {
  description = "Replication Setup for the Storage Account (LRS, ZRS, GRS, etc.)"
  type        = string
  default     = "LRS"
}

variable "allow_public_access" {
  description = "Flag for enabling the public access to the objects on this Storage Account"
  type        = bool
  default     = false
}

variable "containers" {
  description = "List of container names to be created within this Storage Account"
  type        = set(string)
  default     = []
}

variable "shares" {
  description = "Map of shares to be created within this Storage Account, containing config parameters"
  type        = map(any)
  default     = {}
}
