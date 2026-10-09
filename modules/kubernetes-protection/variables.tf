variable "cluster_names" {
  description = "Exact Rubrik inventory names of Kubernetes clusters to protect. Each name must resolve to exactly one cluster."
  type        = set(string)
  default     = []
}

variable "protection_set_names" {
  description = "Exact Rubrik inventory names of Kubernetes protection sets to protect. Each name must resolve to exactly one protection set."
  type        = set(string)
  default     = []
}

variable "namespaces" {
  description = "Kubernetes namespaces to protect, keyed by stable Terraform keys and identified by exact cluster and namespace names."
  type = map(object({
    cluster_name   = string
    namespace_name = string
  }))
  default = {}
}

variable "sla_id" {
  description = "Rubrik ID of the existing SLA Domain to assign to the Kubernetes objects."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.sla_id))
    error_message = "The SLA Domain ID must be a UUID."
  }
}
