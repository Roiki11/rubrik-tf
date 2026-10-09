variable "share_ids" {
  description = "Rubrik IDs of existing NAS shares to protect."
  type        = set(string)

  validation {
    condition = alltrue([
      for id in var.share_ids :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "Every NAS share ID must be a UUID."
  }
}

variable "sla_id" {
  description = "Rubrik ID of the existing SLA Domain to assign to each NAS share."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.sla_id))
    error_message = "The SLA Domain ID must be a UUID."
  }
}
