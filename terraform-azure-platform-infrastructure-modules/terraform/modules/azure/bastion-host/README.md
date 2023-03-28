## Bastion Host

This module is intended to create an Azure VM with a standardized and pre-defined configuration to be used as Bastion Host (a.k.a. Jump Host) to control the access to the private resources hosted in Azure.

Example usage:

```
module "bastion" {
  source  = "app.terraform.io/Kognitiv/platform-infrastructure-modules/azure//terraform/modules/azure/subnet"
  version = "x.y.z"                                  # Kognitiv's Terraform Module version to use

  release_version = "1"

  resource_group_name = var.resource_group_name
  location            = var.location

  ssh_source_address_list = ["XXX.XXX.XXX.XXX"]      # List of Public IPs to be allowed via SSH

  vnet_name = var.vnet_name
  subnet_id = var.subnet_id

  ssh_key = "ssh-rsa AAAA...."                       # The SSH Public Key for the `azureuser` admin user. 

  global_common_tags         = local.global_common_tags
  subscription_common_tags   = local.subscription_common_tags
  environment_common_tags    = local.environment_common_tags
  resource_group_common_tags = local.resource_group_common_tags
  role_common_tags           = local.role_common_tags
}
```

- The Bastion Host will be always a Linux VM with a pre-defined Ubuntu LTS version installed (right now 20.04 LTS).
- On creation, only the `azureuser` admin user will be created, and will enable the access using the SSH Key Pair configured on the `ssh_key` parameter.
- Bastion host should be provisioned after deployments with manual or IaC-like tools, but provisioning is not covered by this module.
