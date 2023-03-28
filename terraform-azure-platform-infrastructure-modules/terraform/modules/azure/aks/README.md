## AKS Cluster

This module is intended to create an AKS cluster and encompasses all of the underlying components required to build a cluster. This includes the nat-gateway, subnet & public-ip for the nat-gateway. 


Example usage:

```
module "aks" {
  source  = "app.terraform.io/Kognitiv/platform-infrastructure-modules/azure//terraform/modules/azure/aks"
  version = "x.y.z"                                  # Kognitiv's Terraform Module version to use

  resource_group_name              = "kps-nonprod-rg"
  vnet_name                        = "kps-nonprod-vnet"

  aks_cluster_name                 = "kps-nonprod-aks"
  aks_cluster_version              = "1.20.2"
  aks_cluster_acr_name             = "kpscontainerreg"
  acr_resource_group_name          = "kps-dev-rg"
  aks_node_pool_subnet_cidr        = "10.1.0.0/17"

  k8s_docker_bridge_cidr           = "172.17.0.1/16"
  k8s_service_cidr                 = "10.0.0.0/16"
  k8s_dns_service_ip               = "10.0.0.10"

  system_node_pool_vm_size         = "Standard_B2s"
  system_pool_node_count           = 1
  system_node_pool_max_pods        = 30

  user_node_pool_vm_size           = "Standard_B2s"
  user_pool_node_count             = 3
  user_node_pool_max_pods          = 30

  enable_node_pool_host_encryption = false 

  admin_group_ad_ids = ["9319a1ce-b937-4738-9ff6-ca82deb87175"]

  global_common_tags         = local.global_common_tags
  subscription_common_tags   = local.subscription_common_tags
  environment_common_tags    = local.environment_common_tags
  resource_group_common_tags = local.resource_group_common_tags
  role_common_tags           = local.role_common_tags
}
```

TODO:!!! There also is an expectation that the subscription will be passed from a global variable group as part of this command. In the above example it is included as part of hte `common.hcl` config stack.

This module also support extra custom node pools, which can be created by setting the following var:

```
module "aks" {
  # ...

  custom_node_pools = {
    custom_node_poolA = {
      node_pool_name                   = "customnpa",
      node_pool_vm_size                = "Standard_B2s",
      node_pool_max_pods               = 25,
      node_count                       = 2,
      enable_node_pool_host_encryption = false
    },
    custom_node_poolB = {
      node_pool_name                   = "customnpb",
      node_pool_vm_size                = "Standard_D4s_v3",
      node_pool_max_pods               = 10,
      node_count                       = 6,
      enable_node_pool_host_encryption = false
    }
  }
}
```
If `custom_node_pools` is not defined, then only the default `system` and `user` node pools will be created.
