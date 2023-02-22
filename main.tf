locals {
  uniq = substr(sha1(azurerm_resource_group.example.id), 0, 8)
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_container_group" "example" {
  name                = var.container_group_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  ip_address_type     = "Public"
  dns_name_label      = replace("${var.container_group_name}-${local.uniq}", "_", "-")
  os_type             = "Linux"

  container {
    name   = "inspectorgadget"
    image  = "jelledruyts/inspectorgadget:latest"
    cpu    = "0.5"
    memory = "1.0"

    ports {
      port     = 80
      protocol = "TCP"
    }
  }
}
