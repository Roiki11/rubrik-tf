variable "folder_names" {
  description = "Exact Rubrik inventory names of vSphere folders to assign to the SLA Domain. Each name must be non-empty and resolve to exactly one folder."
  type        = set(string)

  validation {
    condition     = alltrue([for name in var.folder_names : length(trimspace(name)) > 0])
    error_message = "Every vSphere folder name must be non-empty."
  }
}

variable "tag_ids" {
  description = "Rubrik UUIDs of vSphere tags to assign to the SLA Domain; Rubrik does not expose a tag name-to-object-ID lookup."
  type        = set(string)

  validation {
    condition = alltrue([
      for id in var.tag_ids :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "Every vSphere tag ID must be a Rubrik UUID."
  }
}

variable "sla_ids" {
  description = "Valid Rubrik SLA Domain UUIDs keyed as folder:<name> or tag:<UUID>."
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
