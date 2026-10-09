variable "database_cluster_ids" {
  description = "Rubrik IDs of PostgreSQL database clusters to protect."
  type        = set(string)

  validation {
    condition = alltrue([
      for id in var.database_cluster_ids :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "Every PostgreSQL database cluster ID must be a UUID."
  }
}

variable "sla_id" {
  description = "Rubrik ID of the existing SLA Domain to assign to each PostgreSQL database cluster."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.sla_id))
    error_message = "The SLA Domain ID must be a UUID."
  }
}
