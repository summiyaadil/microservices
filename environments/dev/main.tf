module "resource_group" {
  source = "../../modules/resource_group"
  resource_groups = {
    "${var.project_name}-${var.env}-rg" = {
      location = var.location
      tags = {
        Environment = var.env
        Project     = var.project_name
      }
    }
  }
}

module "container_registry" {
  source = "../../modules/container_registry"
  registries = {
    "${var.project_name}${var.env}acr" = {
      resource_group_name = module.resource_group.resource_group_names["${var.project_name}-${var.env}-rg"]
      location            = module.resource_group.resource_group_locations["${var.project_name}-${var.env}-rg"]
      sku                 = "Standard"
      tags = {
        Environment = var.env
        Project     = var.project_name
      }
    }
  }
}

module "kubernetes_cluster" {
  source = "../../modules/kubernetes_cluster"
  clusters = {
    "${var.project_name}-${var.env}-aks" = {
      location            = module.resource_group.resource_group_locations["${var.project_name}-${var.env}-rg"]
      resource_group_name = module.resource_group.resource_group_names["${var.project_name}-${var.env}-rg"]
      dns_prefix          = "${var.project_name}-${var.env}-dns"
      node_count          = 1
      acr_ids             = [module.container_registry.acr_ids["${var.project_name}${var.env}acr"]]
      tags = {
        Environment = var.env
        Project     = var.project_name
      }
      extra_node_pools = {
        "userpool" = {
          node_count = 1
          vm_size    = "Standard_DS2_v2"
        }
      }
    }
  }
}
