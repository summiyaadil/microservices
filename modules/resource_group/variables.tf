variable "resource_groups" {
  description = "A map of resource group configurations"
  type = map(object({
    location = string
    tags     = optional(map(string), {})
  }))
}
