####################
# Output CDN details
####################
# CDN Profile
output "id" {
  value = azurerm_cdn_profile.cdnprofile.id
}

# CDN Endpoints
output "id_endpoints" {
  value = [ for x in azurerm_cdn_endpoint.cdnendpoint : x.id ]
}
