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

  cdn_profile_name = coalesce(var.custom_profile_name, "${local.default_name}-cdn-profile")

  common_tags = merge(
    var.global_common_tags,
    var.subscription_common_tags,
    var.resource_group_common_tags,
    var.environment_common_tags,
    var.role_common_tags,
  )
}

# CDN Profile
resource "azurerm_cdn_profile" "cdnprofile" {
  name                = local.cdn_profile_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard_Microsoft"

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

# CDN endpoints
resource "azurerm_cdn_endpoint" "cdnendpoint" {
  for_each = var.endpoints

  name                      = each.key
  profile_name              = azurerm_cdn_profile.cdnprofile.name
  location                  = var.location
  resource_group_name       = var.resource_group_name

  is_http_allowed           = false
  is_https_allowed          = true
  is_compression_enabled    = true

  content_types_to_compress = ["application/eot", "application/font", "application/font-sfnt", "application/javascript",
                              "application/json", "application/opentype", "application/otf", "application/pkcs7-mime",
                              "application/truetype", "application/ttf", "application/vnd.ms-fontobject", "application/xhtml+xml",
                              "application/xml", "application/xml+rss", "application/x-font-opentype", "application/x-font-truetype",
                              "application/x-font-ttf", "application/x-httpd-cgi", "application/x-javascript", "application/x-mpegurl",
                              "application/x-opentype", "application/x-otf", "application/x-perl", "application/x-ttf", "font/eot",
                              "font/ttf", "font/otf", "font/opentype", "image/svg+xml", "text/css", "text/csv", "text/html",
                              "text/javascript", "text/js", "text/plain", "text/richtext", "text/tab-separated-values", "text/xml",
                              "text/x-script", "text/x-component", "text/x-java-source"]

  origin_host_header        = each.value
  origin {
    name                    = "origin-${each.key}"
    host_name               = each.value
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
