variable "vm_ids" {
  description = "Rubrik IDs of the vSphere VMs to protect."
  type        = set(string)

  validation {
    condition = alltrue([
      for id in var.vm_ids :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "Every vSphere VM ID must be a UUID."
  }
}

variable "sla_id" {
  description = "Rubrik ID of the existing SLA Domain to assign to each VM."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.sla_id))
    error_message = "The SLA Domain ID must be a UUID."
  }
}
