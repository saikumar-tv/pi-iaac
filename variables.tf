variable "rgname" {
    type = string
    default = ""
  
}
variable "location" {
    type = string
    default = ""
  
}
variable "cluster-name" {
    type = string
    default = ""
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
