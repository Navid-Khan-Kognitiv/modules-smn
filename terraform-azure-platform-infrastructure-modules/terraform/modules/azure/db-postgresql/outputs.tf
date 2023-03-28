####################################
# Output PSQL DB Server details
####################################
output "id" {
  value = azurerm_postgresql_server.server.id
}
output "fqdn" {
  value = azurerm_postgresql_server.server.fqdn
}

output "id_replica" {
  value = [ for x in azurerm_postgresql_server.replica : x.id ]
}
output "fqdn_replica" {
  value = [ for x in azurerm_postgresql_server.replica : x.fqdn ]
}
