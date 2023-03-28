##############################
# Output Redis Instace details
##############################
output "id" {
  value = azurerm_redis_cache.instance.id
}

output "hostname" {
  value = azurerm_redis_cache.instance.hostname
}

output "port" {
  value = azurerm_redis_cache.instance.ssl_port
}
