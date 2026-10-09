variable "database_cluster_names" {
  description = "Exact Rubrik inventory names of the PostgreSQL database clusters to protect. Each name must be non-empty and resolve to exactly one cluster."
  type        = set(string)

  validation {
    condition     = alltrue([for name in var.database_cluster_names : length(trimspace(name)) > 0])
    error_message = "Every PostgreSQL database cluster name must be non-empty."
  }
}

variable "sla_ids" {
  description = "Valid Rubrik SLA Domain UUIDs keyed by exact PostgreSQL database cluster name."
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
