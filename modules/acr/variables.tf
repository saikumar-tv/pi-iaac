variable "acr_name" {
  description = "The name of the Azure Container Registry."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the ACR should be created."
  type        = string
}

variable "location" {
  description = "The Azure region where the ACR should be created."
  type        = string
}

variable "aks_principal_id" {
  description = "The principal ID of the AKS cluster's managed identity."
  type        = string
}
