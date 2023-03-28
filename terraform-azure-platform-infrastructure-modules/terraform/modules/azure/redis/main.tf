terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.99.0"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

locals {
  name_prefix  = var.name_prefix != "" ? replace(var.name_prefix, "/[a-z0-9]$/", "$0-") : ""
  default_name = lower("${local.name_prefix}${var.client_name}-${var.location_short}-${var.environment}")

  instance_name = coalesce(var.custom_profile_name, "${local.default_name}-redis")

  # Family attribute depends on the SKU, so we can avoid an extra variable
  family = {
    "Basic"      = "C",
    "Standard"   = "C",
    "Premium"    = "P",
    "Enterprise" = "E",
  }

  common_tags = merge(
    var.global_common_tags,
    var.subscription_common_tags,
    var.resource_group_common_tags,
    var.environment_common_tags,
    var.role_common_tags,
  )
}

# Redis Instance
resource "azurerm_redis_cache" "instance" {
  name                = local.instance_name

  location            = var.location
  resource_group_name = var.resource_group_name

  capacity            = var.capacity
  family              = local.family[var.sku]
  sku_name            = var.sku

  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  public_network_access_enabled = true

  redis_version = 6

  redis_configuration {
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
