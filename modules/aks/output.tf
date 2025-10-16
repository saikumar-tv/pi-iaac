output "kube_config_raw" {
  value = azurerm_kubernetes_cluster.aks-cluster.kube_config_raw
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks-cluster.kube_config
  sensitive = true
}

output "aks_principal_id" {
  value = azurerm_kubernetes_cluster.aks-cluster.identity[0].principal_id
}

output "private_key" {
  value = tls_private_key.pk.private_key_pem
  sensitive = true
}