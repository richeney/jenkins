variable "resource_group_name" {
  description = "Name for the resource group"
  type        = string
  default     = "terraform-demo"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "West Europe"
}

variable "container_group_name" {
  description = "Name of the container group"
  type        = string
  default     = "tfstate"
}

variable "client_id" {
  description = "Client ID (APP ID) of the application"
  type        = string
  default     = null
}

variable "subscription_id" {
  description = "Subscription ID"
  type        = string
  default     = null
}

variable "tenant_id" {
  description = "Tenant ID"
  type        = string
  default     = null
}
