variable "vm_names" {
  description = "Exact Rubrik inventory names of the vSphere VMs to protect. Each name must resolve to exactly one VM."
  type        = set(string)
}

variable "sla_id" {
  description = "Rubrik ID of the existing SLA Domain to assign to each VM."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.sla_id))
    error_message = "The SLA Domain ID must be a UUID."
  }
}
