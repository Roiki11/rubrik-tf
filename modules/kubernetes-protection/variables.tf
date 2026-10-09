variable "cluster_names" {
  description = "Exact Rubrik inventory names of Kubernetes clusters to protect. Each name must be non-empty and resolve to exactly one cluster."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for name in var.cluster_names : length(trimspace(name)) > 0])
    error_message = "Every Kubernetes cluster name must be non-empty."
  }
}

variable "protection_set_names" {
  description = "Exact Rubrik inventory names of Kubernetes protection sets to protect. Each name must be non-empty and resolve to exactly one protection set."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for name in var.protection_set_names : length(trimspace(name)) > 0])
    error_message = "Every Kubernetes protection-set name must be non-empty."
  }
}

variable "namespaces" {
  description = "Kubernetes namespaces to protect, keyed by stable Terraform keys and identified by exact cluster and namespace names."
  type = map(object({
    cluster_name   = string
    namespace_name = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for namespace in values(var.namespaces) :
      length(trimspace(namespace.cluster_name)) > 0 &&
      length(trimspace(namespace.namespace_name)) > 0
    ])
    error_message = "Every Kubernetes namespace requires non-empty cluster_name and namespace_name values."
  }
}

variable "sla_ids" {
  description = "Valid Rubrik SLA Domain UUIDs keyed as cluster:<name>, protection_set:<name>, or namespace:<key>."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for id in values(var.sla_ids) :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "Every SLA ID must be a UUID in 8-4-4-4-12 hexadecimal format."
  }
}
