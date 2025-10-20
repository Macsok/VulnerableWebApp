output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "kube_config_raw" {
  description = "Surowa konfiguracja kubeconfig do połączenia z klastrem AKS."
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}
