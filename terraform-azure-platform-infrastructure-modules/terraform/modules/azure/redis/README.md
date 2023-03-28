## Azure Cache for Redis

This module is intended to create a Redis Instance using the managed Azure Cache for Redis Service.

Example usage:

```
module "redis" {
  source  = "app.terraform.io/Kognitiv/platform-infrastructure-modules/azure//terraform/modules/azure/redis"
  version = "x.y.z"                                  # Kognitiv's Terraform Module version to use

  resource_group_name   = var.resource_group_name
  location              = var.location               # Ex: North Europe
  location_short        = var.location_short         # Ex: neu

  client_name           = var.client_name  # Ex: EEC
  environment           = var.environment  # Ex: dev

  sku                   = "Basic"  # Ex: Basic, Standard, Premium, or Enterprise
  capacity              = 0        # Ex: 0, 1, 2, etc. (Along with the SKU, defines the size of the cache instance)

  global_common_tags         = local.global_common_tags
  subscription_common_tags   = local.subscription_common_tags
  environment_common_tags    = local.environment_common_tags
  resource_group_common_tags = local.resource_group_common_tags
  role_common_tags           = local.role_common_tags
}
```

- This module will create SSL-only cache instances (supporting only TLS >= 1.2), non-SSL ports are not allowed.
- For standardization purposes, Redis version will be always the same (Redis v6.x).
- As private endpoints are allowed only for Premium SKU, for now we support only publicly accessible instances.
- All instances are created with the default configuration for the chosen SKU.

## TODOs
Things that are pending to add on this module:
- Support for private endpoints on Premium SKU.
- Support customization of redis configuration parameters.
