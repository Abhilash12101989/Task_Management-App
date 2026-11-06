variable "rg" {
  description = "Map of resource groups to create"
  type = map(object({
    name     = string
    location = string
  }))
}

variable "tags" {
  description = "Tags for the resource groups"
  type        = map(string)
  default     = {}
}
