## Storage Account

This module is intended to create and manage the different data objects supported by the Azure Storage Account service.

Example usage:

```
module "storage_account" {
  source  = "app.terraform.io/Kognitiv/platform-infrastructure-modules/azure//terraform/modules/azure/storage-account"
  version = "x.y.z"                                  # Kognitiv's Terraform Module version to use

  resource_group_name   = var.resource_group_name
  location              = var.location               # Ex: North Europe
  location_short        = var.location_short         # Ex: neu

  client_name           = var.client_name            # Ex: EEC
  environment           = var.environment            # Ex: dev

  allow_public_access   = false                      # Enable or disable public access to the objects inside the SA (default: false) 

  replication_type      = "GRS"                      # Configures the Storage Account replication (default: LRS)

  access_tier           = "Hot"                      # For configuring Hot or Cool access tier (default: Hot)

  containers = ["containera", "container-b"]         # List with container names (optional)

  shares = {                                         # List with file shares to be created (optional)
      "sharea" = {
          "quota" = "10" 
      },
      "share-b" = {
          "quota" = "15" 
      },
  }

  global_common_tags         = local.global_common_tags
  subscription_common_tags   = local.subscription_common_tags
  environment_common_tags    = local.environment_common_tags
  resource_group_common_tags = local.resource_group_common_tags
  role_common_tags           = local.role_common_tags
}
```

- Only HTTPS traffic with TLS v1.2 is supported.
- All storage accounts are created on Standard tier and Storage V2 type.
- The module support the creation of Blob Containers and File Shares inside the Storage Account. Both `containers` and `shares` parameters are optionals, if absent, no object of that kind will be created on the Storage Account.
- Blob Containers are created only with default options so far.
- File Shares only supports customization of storage quota.

## TODOs
Things that are pending to add on this module:
- Extend the module to enable extra configuration parameters both for containers and shares.
- If different tiers or types are required, the module can be extended by adding more input vars.
