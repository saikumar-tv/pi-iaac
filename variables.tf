variable "rgname" {
    type = string
    default = "PI-AKS-rg"
  
}
variable "location" {
    type = string
    default = "Central India"
  
}
variable "cluster-name" {
    type = string
    default = "PI-aks-cluster"
}

variable "admin_users" {
  description = "List of sample admin usernames for Kubernetes RBAC."
  type        = list(string)
  default     = ["admin-user-1", "admin-user-2"]
}

variable "dev_users" {
  description = "List of sample dev usernames for Kubernetes RBAC."
  type        = list(string)
  default     = ["dev-user-1", "dev-user-2"]
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
  default     = "pi-aks-log-workspace"
}

variable "aks_disk_encryption_set_id" {
  description = "The ID of the Disk Encryption Set to use for AKS OS and Data Disks."
  type        = string
  default     = ""
}

variable "key_vault_id" {
  description = "The ID of the Key Vault to use for Disk Encryption Set."
  type        = string
}

variable "key_vault_key_id" {
  description = "The ID of the Key Vault Key to use for Disk Encryption Set."
  type        = string
}

variable "tenant_id" {
  description = "The Azure Tenant ID."
  type        = string
}
