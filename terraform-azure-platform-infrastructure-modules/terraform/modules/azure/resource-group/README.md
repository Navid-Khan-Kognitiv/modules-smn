## Resource Group

This module is intended to create and manage Azure Resource Groups following our standards for naming and tagging.

Example usage:

```
module "resource_group" {
  source = "app.terraform.io/Kognitiv/platform-infrastructure-modules/azure//terraform/modules/azure/resource-group"
  version = "x.y.z"                                  # Kognitiv's Terraform Module version to use

  rsg_name     = "my-rg-name"
  rsg_location = local.location

  rsg_environment_tag = local.environment
  rsg_owner_tag       = "Serafin Cepeda"
  rsg_application_tag = "Terraform Cloud"
  rsg_project_tag     = "Terraform Cloud PoC"

}
```

## TODOs
Things that are pending to add on this module:
- ...
