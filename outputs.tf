output "ip_addresses" {
  value = azurerm_container_app.example.outbound_ip_addresses
}

output "fqdn" {
  value = azurerm_container_app.example.latest_revision_fqdn
}
