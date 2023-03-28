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

provider "azurerm" {
  alias = "ccp-dev-tools"
  subscription_id = var.dev_tools_subscription_id
  features {}
}


# Define common tags for all resources
locals {
  common_tags = merge(
    var.global_common_tags,
    var.subscription_common_tags,
    var.resource_group_common_tags,
    var.environment_common_tags,
    var.role_common_tags,
    {
      release_version = var.release_version
    },
    {
      vnet = var.vnet_name
    },
    {
      role = var.role_common_tags.role_name
    }
  )
}

# Get subscription details
data "azurerm_subscription" "subscription" {
  subscription_id = var.subscription_id
}

# Fetch existing resource group details from azure
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

# Fetch existing vnet details to verify network exists
data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.resource_group.name
}



##########################################################
# Create managed identity and assign required role to it
##########################################################
# Get existing role definition
data "azurerm_role_definition" "contributor" {
  name = "Network Contributor"
}

# Fetching managed system identity for the AKS Cluster post its creation
resource "azurerm_user_assigned_identity" "aks_agentpool_identity" {
  name                = "${var.aks_cluster_name}-identity"
  resource_group_name = var.resource_group_name
  location            = data.azurerm_resource_group.resource_group.location
  tags                = local.common_tags
}

# Assigning AKS SP identity as "Network Contributor" access
resource "azurerm_role_assignment" "aksnodepoolsubnet_role_assignment" {
  scope                            = data.azurerm_subscription.subscription.id
  role_definition_id               = "${data.azurerm_subscription.subscription.id}${data.azurerm_role_definition.contributor.id}"
  principal_id                     = azurerm_user_assigned_identity.aks_agentpool_identity.principal_id
  skip_service_principal_aad_check = true
}

# Waiting for 2 minutes before continuing since managed identity takes some time to be fully available
resource "null_resource" "wait_for_resource_to_be_ready" {
  provisioner "local-exec" {
    command = "sleep 180"
  }
  depends_on = [
    azurerm_role_assignment.aksnodepoolsubnet_role_assignment
  ]
}

# Grant pull access to ACR
data "azurerm_container_registry" "acr" {
  provider = azurerm.ccp-dev-tools
  name                = var.aks_cluster_acr_name
  resource_group_name = var.acr_resource_group_name
  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

data "azurerm_user_assigned_identity" "aks_agent_pool_managed_identity" {
  name                = "${var.aks_cluster_name}-agentpool"
  resource_group_name = "MC_${var.resource_group_name}_${var.aks_cluster_name}_${data.azurerm_resource_group.resource_group.location}"
  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

resource "azurerm_role_assignment" "acrpull_role" {
  scope                            = data.azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = data.azurerm_user_assigned_identity.aks_agent_pool_managed_identity.principal_id
  skip_service_principal_aad_check = true

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}


##########################################################
# Create AKS Node Pool Private Subnet
##########################################################

resource "azurerm_subnet" "aksnodepoolsubnet" {
  name                 = "privatesubnet-${var.aks_cluster_name}-node-pool"
  resource_group_name  = data.azurerm_resource_group.resource_group.name
  virtual_network_name = var.vnet_name

  address_prefixes = [var.aks_node_pool_subnet_cidr]

  service_endpoints = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.Storage"]

  enforce_private_link_endpoint_network_policies = "true"
}

############################################################
# Create AKS Cluster
############################################################
resource "azurerm_kubernetes_cluster" "aks" {
  name                    = var.aks_cluster_name
  resource_group_name     = data.azurerm_resource_group.resource_group.name
  location                = data.azurerm_resource_group.resource_group.location
  dns_prefix              = var.aks_cluster_name
  private_cluster_enabled = "true"
  private_dns_zone_id     = "System"
  kubernetes_version      = var.aks_cluster_version
  tags                    = local.common_tags

  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    load_balancer_sku  = "standard"
    docker_bridge_cidr = var.k8s_docker_bridge_cidr
    service_cidr       = var.k8s_service_cidr
    dns_service_ip     = var.k8s_dns_service_ip
    outbound_type      = "userAssignedNATGateway"
  }

  identity {
    type                      = "UserAssigned"
    user_assigned_identity_id = azurerm_user_assigned_identity.aks_agentpool_identity.id
  }

  role_based_access_control {
    enabled = true

    azure_active_directory {
      managed                = true
      admin_group_object_ids = var.admin_group_ad_ids
      tenant_id              = var.admin_group_ad_tenant_id
    }
  }

  addon_profile {
    aci_connector_linux {
      enabled = false
    }

    azure_policy {
      enabled = false
    }

    http_application_routing {
      enabled = false
    }

    oms_agent {
      enabled = false
    }
  }

  # System Node Pool
  default_node_pool {
    name                         = "systempool1"
    vnet_subnet_id               = azurerm_subnet.aksnodepoolsubnet.id
    vm_size                      = var.system_node_pool_vm_size
    max_pods                     = var.system_node_pool_max_pods
    node_count                   = var.system_pool_node_count
    enable_host_encryption       = var.enable_node_pool_host_encryption
    availability_zones           = ["1", "2", "3"]
    type                         = "VirtualMachineScaleSets"
    only_critical_addons_enabled = "true"
    node_labels = {
      "node_pool_type" = "systempool1"
    }
  }

  # Make sure managed identity is created before creating AKS
  depends_on = [
    null_resource.wait_for_resource_to_be_ready
  ]
}


# User Node pool1
resource "azurerm_kubernetes_cluster_node_pool" "userpool1" {
  name                   = "userpool1"
  kubernetes_cluster_id  = azurerm_kubernetes_cluster.aks.id
  vnet_subnet_id         = azurerm_subnet.aksnodepoolsubnet.id
  vm_size                = var.user_node_pool_vm_size
  max_pods               = var.user_node_pool_max_pods
  node_count             = var.user_pool_node_count
  enable_host_encryption = var.enable_node_pool_host_encryption
  availability_zones     = ["1", "2", "3"]
  node_labels = {
    "node_pool_type" = "standardpool1",
  }
  os_type = "Linux"

  tags = local.common_tags
}

# Custom Extra Node Pools
resource "azurerm_kubernetes_cluster_node_pool" "custompool" {
  for_each               = var.custom_node_pools

  os_type                = "Linux"

  name                   = each.value.node_pool_name
  kubernetes_cluster_id  = azurerm_kubernetes_cluster.aks.id
  vnet_subnet_id         = azurerm_subnet.aksnodepoolsubnet.id
  vm_size                = each.value.node_pool_vm_size
  max_pods               = each.value.node_pool_max_pods
  node_count             = each.value.node_count
  enable_host_encryption = each.value.enable_node_pool_host_encryption
  availability_zones     = ["1", "2", "3"]

  node_labels = {
    "node_pool_type" = "custompool",
  }

  tags = local.common_tags
}

############################################################
# NAT Gateway related resources
############################################################
resource "azurerm_public_ip" "publicip" {
  name                = "${var.aks_cluster_name}-node-pool-natgw-publicip"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
  tags                = local.common_tags
}

resource "azurerm_nat_gateway" "natgateway" {
  name                    = "${var.aks_cluster_name}-node-pool-natgw"
  location                = data.azurerm_resource_group.resource_group.location
  resource_group_name     = var.resource_group_name
  zones                   = ["1"]
  sku_name                = "Standard"
  idle_timeout_in_minutes = 4
  tags                    = local.common_tags
}

resource "azurerm_nat_gateway_public_ip_association" "nat_publicip" {
  nat_gateway_id       = azurerm_nat_gateway.natgateway.id
  public_ip_address_id = azurerm_public_ip.publicip.id
}

resource "azurerm_subnet_nat_gateway_association" "akssubnetregionalnat_aksnodepoolsubnet_association" {
  subnet_id      = azurerm_subnet.aksnodepoolsubnet.id
  nat_gateway_id = azurerm_nat_gateway.natgateway.id
}
