variable "aks_cluster_name" {
  type        = string
  description = "AKS Cluster Name"
}

variable "location" {
  type        = string
  description = "Azure Region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group Name"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics Workspace ID for AKS monitoring"
}

variable "aks_disk_encryption_set_id" {
  type        = string
  description = "The ID of the Disk Encryption Set to use for AKS OS and Data Disks."
}
