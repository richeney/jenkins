locals {
  uniq = substr(sha1(azurerm_resource_group.example.id), 0, 8)
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "example-workspace"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Free"
  retention_in_days   = 7
}

resource "azurerm_container_app_environment" "example" {
  name                       = "example-environment"
  location                   = azurerm_resource_group.example.location
  resource_group_name        = azurerm_resource_group.example.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
}

resource "azurerm_container_app" "example" {
  name                         = "example-app"
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = azurerm_resource_group.example.name
  revision_mode                = "Single"

  identity {
    type = "SystemAssigned"
  }

  template {
    container {
      name   = "inspectorgadget"
      image  = "jelledruyts/inspectorgadget:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "AZURE_LOCATION"
        value = azurerm_container_app_environment.example.location
      }

      env {
        name  = "AZURE_RESOURCE_GROUP"
        value = azurerm_container_app_environment.example.name
      }
    }
  }
}
