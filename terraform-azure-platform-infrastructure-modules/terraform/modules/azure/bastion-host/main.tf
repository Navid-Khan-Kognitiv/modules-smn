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

# Define common tags for all resources
locals {
  admin_username = "azureuser"
  vm_name        = "${var.vnet_name}-bastion-vm"

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
    }
  )
}

#######################################################
# Bastion Server (Management Server)
#######################################################

# Fetch existing resource group details from azure
data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

# Create PublicIp for bastion server
resource "azurerm_public_ip" "publicip" {
  name                = "${local.vm_name}-publicip"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "vm_nsg" {
  name                = "${local.vm_name}-nsg"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name
  tags                = local.common_tags
}

resource "azurerm_network_security_rule" "bastion_vm_nsg_rule" {
  name                        = "ssh_${local.vm_name}"
  priority                    = 999
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefixes     = var.ssh_source_address_list
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = 22
  resource_group_name         = data.azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.vm_nsg.name
}

# Create network interface
resource "azurerm_network_interface" "vm_nic" {
  name                = "${local.vm_name}-nic"
  location            = data.azurerm_resource_group.resource_group.location
  resource_group_name = data.azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "${local.vm_name}-nic-ip-config"
    subnet_id                     = var.subnet_id
    public_ip_address_id          = azurerm_public_ip.publicip.id
    private_ip_address_allocation = "Dynamic"
    private_ip_address_version    = "IPv4"
    primary                       = true
  }

  tags = local.common_tags
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nsg_nic_association" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = local.vm_name
  location              = data.azurerm_resource_group.resource_group.location
  resource_group_name   = data.azurerm_resource_group.resource_group.name
  network_interface_ids = [azurerm_network_interface.vm_nic.id]
  size                  = var.vm_size

  os_disk {
    name                 = "${local.vm_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = var.vm_storage_account_type
    disk_size_gb         = var.vm_disk_size_gb
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "20.04.202209200"
 }

  computer_name                   = local.vm_name
  admin_username                  = local.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = local.admin_username
    public_key = var.ssh_key
  }

  tags = local.common_tags
}
