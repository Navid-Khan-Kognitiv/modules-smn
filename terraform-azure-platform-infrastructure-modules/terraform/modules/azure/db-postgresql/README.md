## db-postgresql

This module is intended to create an Azure Database for PostgreSQL server, with an optional remote read-only replica for DR.

Example usage:

```
module "psql_server" {
  source  = "app.terraform.io/Kognitiv/platform-infrastructure-modules/azure//terraform/modules/azure/db-postgresql"
  version = "x.y.z"                                  # Kognitiv's Terraform Module version to use

  db_admin              = "psql"
  db_pwd                = var.admin_password

  resource_group_name   = var.resource_group_name
  location              = var.location               # Ex: North Europe
  location_short        = var.location_short         # Ex: neu

  client_name           = var.client_name            # Ex: EEC
  environment           = var.environment            # Ex: dev

  db_storage_mb         = 5120
  db_auto_grow_enabled  = false

  create_remote_replica = true                       # Can be set to false to create only the primary server
  replica_location      = var.dr_location            # Ex: West Europe

  public_network_access = true

  fw_allowed_ips = {
   "LPPDC-VPN"       = "54.232.165.254"
   "OVH-CV-Redash"   = "91.134.250.209"
   "OVH-FRA-Redash0" = "135.125.240.129"
   "OVH-FRA-Redash1" = "135.125.253.174"
  }

  fw_allowed_vnets = {
    "eec-vnet-subnet001" = var.subnet_id
  }

  database_names = [
    "eec-avc",
    "eec-async-avc",
    "eec-cv",
    "eec-async-cv",
  ]

  global_common_tags         = local.global_common_tags
  subscription_common_tags   = local.subscription_common_tags
  environment_common_tags    = local.environment_common_tags
  resource_group_common_tags = local.resource_group_common_tags
  role_common_tags           = local.role_common_tags
}
```

## TODOs
Things that are pending to add on this module:
- Private-only network access model: Current setup only allows access from a public network if the incoming connection is allowed by the fw rules.
