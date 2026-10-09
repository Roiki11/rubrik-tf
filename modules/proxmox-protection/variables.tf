variable "objects" {
  description = "Proxmox objects to protect, keyed by stable Terraform keys and identified by exact inventory name and object type."
  type = map(object({
    name        = string
    object_type = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for object in values(var.objects) :
      contains(["PROXMOX_ENVIRONMENT", "PROXMOX_CLUSTER", "PROXMOX_NODE", "PROXMOX_VIRTUAL_MACHINE"], object.object_type)
    ])
    error_message = "Proxmox object_type must be PROXMOX_ENVIRONMENT, PROXMOX_CLUSTER, PROXMOX_NODE, or PROXMOX_VIRTUAL_MACHINE."
  }
}

variable "sla_id" {
  description = "Rubrik ID of the existing SLA Domain to assign to each Proxmox object."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.sla_id))
    error_message = "The SLA Domain ID must be a UUID."
  }
}
