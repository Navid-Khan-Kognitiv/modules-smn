## Subnet

This module is intended to create an Azure Subnet within a VNet.

Example usage:

```
module "subnet" {
  source  = "app.terraform.io/Kognitiv/platform-infrastructure-modules/azure//terraform/modules/azure/subnet"
  version = "x.y.z"                                  # Kognitiv's Terraform Module version to use

  resource_group_name   = var.resource_group_name
  virtual_network_name  = var.virtual_network_name   # Ex: eec-prod-vnet

  location_short        = var.location_short         # Ex: neu

  client_name           = var.client_name            # Ex: EEC
  environment           = var.environment            # Ex: dev

  subnet_cidr_list      = ["10.15.1.0/24"]
}
```

- Subnet will be created with our standard naming convention `[clientname]-[locationshort]-[environment]-subnet` (Ex: `eec-neu-prod-subnet`) by default, unless `custom_subnet_name` parameter is provided.
- This module supports the association of a custom NSG by using the parameter `network_security_group_name` (if the NSG is on a different RG, it can be configured by also adding the `network_security_group_rg` parameter).
- This module also supports the association of a custom Route Table by using the parameter `route_table_name` (if the Route Table is on a different RG, it can be configured by also adding the `route_table_rg` parameter).

## TODOs (before fully releasing the module)
- Add proper tagging 
