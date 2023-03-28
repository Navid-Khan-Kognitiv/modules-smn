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

#################
# Inputs for CDNs
#################
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

variable "custom_profile_name" {
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

variable "endpoints" {
  description = "Map with {endpoint_name: origin} endpoints to be created on the CDN profile"
  default     = {}
  type        = map
}
