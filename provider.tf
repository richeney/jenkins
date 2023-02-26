
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.30.0"
    }
  }

  backend "azurerm" {
    # tenant_id            = // ARM_TENANT_ID, defaults to the user's tenant
    # subscription_id      = // ARM_SUBSCRIPTION_ID, defaults to the user's subscription
    # resource_group_name  = Set in the workflow with --backend-config
    # storage_account_name = Set in the workflow with --backend-config
    container_name = "tfstate"
    key            = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  # tenant_id           = // ARM_TENANT_ID, defaults to the user's tenant
  # subscription_id     = // ARM_SUBSCRIPTION_ID, defaults to the user's subscription
  # client_id           = // ARM_CLIENT_ID, defaults to the client of the user running the command
  # client_secret           = // ARM_CLIENT_SECRET, defaults to the client of the user running the command
  storage_use_azuread = true
}
