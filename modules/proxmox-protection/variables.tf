variable "objects" {
  description = "Proxmox objects to protect, keyed by stable Terraform keys. object_type must be PROXMOX_ENVIRONMENT, PROXMOX_CLUSTER, PROXMOX_NODE, or PROXMOX_VIRTUAL_MACHINE."
  type = map(object({
    name        = string
    object_type = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for object in values(var.objects) :
      length(trimspace(object.name)) > 0 &&
      contains(["PROXMOX_ENVIRONMENT", "PROXMOX_CLUSTER", "PROXMOX_NODE", "PROXMOX_VIRTUAL_MACHINE"], object.object_type)
    ])
    error_message = "Every Proxmox object requires a non-empty name and object_type of PROXMOX_ENVIRONMENT, PROXMOX_CLUSTER, PROXMOX_NODE, or PROXMOX_VIRTUAL_MACHINE."
  }
}

variable "sla_ids" {
  description = "Valid Rubrik SLA Domain UUIDs keyed as object:<Terraform object key>."
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
