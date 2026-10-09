variable "database_cluster_names" {
  description = "Exact Rubrik inventory names of the PostgreSQL database clusters to protect. Each name must resolve to exactly one cluster."
  type        = set(string)
}

variable "sla_ids" {
  description = "SLA Domain IDs keyed by exact PostgreSQL database cluster name."
  type        = map(string)
  default     = {}
}
