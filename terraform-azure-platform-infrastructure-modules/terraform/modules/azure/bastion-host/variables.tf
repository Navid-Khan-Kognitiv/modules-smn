#########################################
# List of Default Variables
#########################################
variable "release_version" {
  type = string
}
variable "global_common_tags" {
  type = map(any)
}
variable "subscription_common_tags" {
  type = map(any)
}
variable "resource_group_common_tags" {
  type = map(any)
}
variable "environment_common_tags" {
  type = map(any)
}
variable "role_common_tags" {
  type = map(any)
}

####################################
# Inputs for bastion server
####################################
variable "vnet_name" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "vm_size" {
  type    = string
  default = "Standard_B2s"
}
variable "ssh_source_address_list" {
  type = list(string)
}
variable "ssh_key" {
  type = string
}
variable "vm_disk_size_gb" {
  type = number
  default = 40
}
variable "vm_storage_account_type" {
  type = string
  default = "Standard_LRS"
}
