variable "folder_ids" {
  description = "Rubrik IDs of vSphere folders to assign to the SLA Domain."
  type        = set(string)

  validation {
    condition = alltrue([
      for id in var.folder_ids :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "Every vSphere folder ID must be a UUID."
  }
}

variable "tag_ids" {
  description = "Rubrik IDs of vSphere tags to assign to the SLA Domain."
  type        = set(string)

  validation {
    condition = alltrue([
      for id in var.tag_ids :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "Every vSphere tag ID must be a UUID."
  }
}

variable "sla_id" {
  description = "Rubrik ID of the SLA Domain to assign to each vSphere folder and tag."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.sla_id))
    error_message = "The SLA Domain ID must be a UUID."
  }
}
