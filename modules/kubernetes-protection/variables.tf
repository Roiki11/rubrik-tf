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

variable "sla_ids" {
  description = "SLA Domain IDs keyed as cluster:<name>, protection_set:<name>, or namespace:<key>."
  type        = map(string)
  default     = {}
}
