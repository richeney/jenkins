output "ip_addresses" {
  value = azurerm_container_app.example.outbound_ip_addresses
}

output "fqdn" {
  value = azurerm_container_app.example.latest_revision_fqdn
}

/*
output "ip_address" {
  value = azurerm_container_group.example.ip_address
}

output "fqdn" {
  value = "http://${azurerm_container_group.example.fqdn}"
}
*/
