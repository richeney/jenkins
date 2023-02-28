
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.45.0"
    }
  }

  backend "azurerm" {
    # tenant_id            = // ARM_TENANT_ID
    # subscription_id      = // ARM_SUBSCRIPTION_ID
    # resource_group_name  = // terraform init --backend-config="resource_group_name=$ARM_BACKEND_RESOURCEGROUP" \
    # storage_account_name = //                --backend-config="storage_account_name=$ARM_BACKEND_STORAGEACCOUNT"
    container_name = "tfstate"
    key            = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  # tenant_id           = // ARM_TENANT_ID
  # subscription_id     = // ARM_SUBSCRIPTION_ID
  # use_msi             = // ARM_USE_MSI (set to true for system/user assigned managed identity)
  # client_id           = // ARM_CLIENT_ID, appId for service principal or user assigned managed identity)
  # client_secret       = // ARM_CLIENT_SECRET, password for service principal
  storage_use_azuread = true
}
