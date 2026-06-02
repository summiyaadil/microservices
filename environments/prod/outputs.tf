output "resource_group_names" {
  value = module.resource_group.resource_group_names
}

output "acr_login_servers" {
  value = module.container_registry.acr_login_servers
}

output "aks_cluster_names" {
  value = module.kubernetes_cluster.cluster_names
}
