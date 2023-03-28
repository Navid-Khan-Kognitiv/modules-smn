## Virtual Network

This module is intended to create an Azure VNet.

Example usage:

```
module "vnet" {
  source  = "app.terraform.io/Kognitiv/platform-infrastructure-modules/azure//terraform/modules/azure/virtual-network"
  version = "x.y.z"                                  # Kognitiv's Terraform Module version to use

  name                = "eec-prod-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location                 # Ex: North Europe
  address_space       = ["10.15.0.0/16"]
}
```

## TODOs (before fully releasing the module)
- Add proper tagging and naming
