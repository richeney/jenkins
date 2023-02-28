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
