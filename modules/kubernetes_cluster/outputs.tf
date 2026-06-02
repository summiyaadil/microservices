output "cluster_names" {
  value = { for k, v in azurerm_kubernetes_cluster.aks : k => v.name }
}

output "cluster_ids" {
  value = { for k, v in azurerm_kubernetes_cluster.aks : k => v.id }
}

output "kube_configs" {
  value     = { for k, v in azurerm_kubernetes_cluster.aks : k => v.kube_config_raw }
  sensitive = true
}
