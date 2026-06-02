resource "azurerm_log_analytics_workspace" "aks" {
  for_each = var.clusters

  name                = "${each.key}-law"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_kubernetes_cluster" "aks" {
  for_each = var.clusters

  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  dns_prefix          = each.value.dns_prefix

  default_node_pool {
    name       = "default"
    node_count = each.value.node_count
    vm_size    = each.value.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = each.value.network_plugin
    load_balancer_sku = "standard"
  }

  azure_policy_enabled = true

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks[each.key].id
  }

  role_based_access_control_enabled = true

  tags = each.value.tags
}

# Nested Map Iteration for Extra Node Pools
locals {
  node_pools = flatten([
    for cluster_key, cluster in var.clusters : [
      for pool_key, pool in cluster.extra_node_pools : {
        cluster_key = cluster_key
        pool_key    = pool_key
        node_count  = pool.node_count
        vm_size     = pool.vm_size
      }
    ]
  ])
}

resource "azurerm_kubernetes_cluster_node_pool" "extra" {
  for_each = { for np in local.node_pools : "${np.cluster_key}_${np.pool_key}" => np }

  name                  = each.value.pool_key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks[each.value.cluster_key].id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count

  tags = var.clusters[each.value.cluster_key].tags
}

# Conditional Iteration for Role Assignments
locals {
  role_assignments = flatten([
    for cluster_key, cluster in var.clusters : [
      for acr_id in cluster.acr_ids : {
        cluster_key = cluster_key
        acr_id      = acr_id
      }
    ]
  ])
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  for_each = { for ra in local.role_assignments : "${ra.cluster_key}_${ra.acr_id}" => ra }

  principal_id                     = azurerm_kubernetes_cluster.aks[each.value.cluster_key].kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = each.value.acr_id
  skip_service_principal_aad_check = true
}
