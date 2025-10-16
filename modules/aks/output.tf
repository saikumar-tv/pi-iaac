output "kube_config_raw" {
  value = azurerm_kubernetes_cluster.aks-cluster.kube_config_raw
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks-cluster.kube_config
  sensitive = true
}

output "host" {
  value = azurerm_kubernetes_cluster.aks-cluster.kube_config.0.host
  sensitive = true
}

output "aks_principal_id" {
  description = "The principal ID of the AKS cluster's managed identity."
  value       = azurerm_kubernetes_cluster.aks-cluster.identity[0].principal_id
}
