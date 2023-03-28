provider "azurerm" {
  features {}
}

locals {
  name_prefix  = var.name_prefix != "" ? replace(var.name_prefix, "/[a-z0-9]$/", "$0-") : ""
  default_name = lower("${local.name_prefix}${var.client_name}${var.location_short}${var.environment}")

  storage_account_name = coalesce(var.custom_storage_account_name, "${local.default_name}sa")

  common_tags = merge(
    var.global_common_tags,
    var.subscription_common_tags,
    var.resource_group_common_tags,
    var.environment_common_tags,
    var.role_common_tags,
  )
}

# Storage Account
resource "azurerm_storage_account" "sa" {
  name                = local.storage_account_name
  resource_group_name = var.resource_group_name

  location                 = var.location
  access_tier              = var.access_tier
  account_tier             = "Standard"
  account_kind             = "StorageV2"                       # Default to Standard Storage v2
  account_replication_type = var.replication_type

  min_tls_version           = "TLS1_2"
  enable_https_traffic_only = true

  allow_blob_public_access  = var.allow_public_access
  shared_access_key_enabled = true

  network_rules {
    default_action = "Allow"                                   # Enable access from all networks
  }

  tags = merge(
    local.common_tags,
    var.tags,
    {
      "environment" = var.environment,
      "capability"  = var.client_name,
      "Terraform"   = "true"
    }
  )
}

# Blob Containers
resource "azurerm_storage_container" "container" {
  for_each = var.containers

  name                  = each.value
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

# File Shares
resource "azurerm_storage_share" "share" {
  for_each = var.shares

  name                  = each.key
  storage_account_name  = azurerm_storage_account.sa.name
  quota                 = each.value.quota

  enabled_protocol = "SMB"
}
