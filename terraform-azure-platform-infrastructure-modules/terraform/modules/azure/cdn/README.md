## CDN

This module is intended to create a CDN Profile and one or multiple endpoints.

Example usage:

```
module "cdn" {
  source  = "app.terraform.io/Kognitiv/platform-infrastructure-modules/azure//terraform/modules/azure/cdn"
  version = "x.y.z"                                  # Kognitiv's Terraform Module version to use

  resource_group_name   = var.resource_group_name
  location              = var.location               # Ex: North Europe
  location_short        = var.location_short         # Ex: neu

  client_name           = var.client_name            # Ex: EEC
  environment           = var.environment            # Ex: dev

  endpoints = {
    "www-kognitiv-test" = "www.kognitiv.com"         # Ex: Endpoint Name = Origin Domain
    "hotels-kognitiv-test" = "hotels.kognitiv.com"
  }

  global_common_tags         = local.global_common_tags
  subscription_common_tags   = local.subscription_common_tags
  environment_common_tags    = local.environment_common_tags
  resource_group_common_tags = local.resource_group_common_tags
  role_common_tags           = local.role_common_tags
}
```

- All the endpoints will be created inside the same CDN Profile.
- The SKU will be always `Standard_Microsoft`.
- The CDN Endpoints will always deny HTTP, accept only HTTPS, and have compression enabled for all the supported MIME-Types.
- With the current setup, each endpoint supports one origin, which will be configured with the domain defined for that endpoint.
- The endpoint domains will be created as: `{EndpointName}.azureedge.net`. (Ex: for ` "www-kognitiv-test" = "www.kognitiv.com"` the module will create the `https://www-kognitiv-test.azureedge.net/` endpoint, using as origin `https://www.kognitiv.com/`).


## TODOs
Things that are pending to add on this module:
- Custom Delivery Rules, endpoints are now created only with the default rules.
- Actions for modifying request/response headers.
- Support for custom domains on CDN endpoints.
