################################
# Output Storage Account details
################################
output "id" {
  value = azurerm_storage_account.sa.id
}

# Blob Containers
output "id_containers" {
  value = [ for x in azurerm_storage_container.container : x.id ]
}

# File Shares
output "id_shares" {
  value = [ for x in azurerm_storage_share.share: x.id ]
}
