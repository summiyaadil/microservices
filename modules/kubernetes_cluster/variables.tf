variable "clusters" {
  description = "A map of AKS cluster configurations"
  type = map(object({
    resource_group_name = string
    location            = string
    dns_prefix          = string
    node_count          = optional(number, 1)
    vm_size             = optional(string, "Standard_DS2_v2")
    tags                = optional(map(string), {})
    network_plugin      = optional(string, "azure")
    extra_node_pools = optional(map(object({
      node_count = number
      vm_size    = string
    })), {})
    acr_ids = optional(list(string), [])
  }))
}
