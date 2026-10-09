variable "shares" {
  description = "Existing NAS Cloud Direct shares to protect, keyed by stable Terraform names and identified by non-empty exact share and system names."
  type = map(object({
    name        = string
    system_name = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for share in values(var.shares) :
      length(trimspace(share.name)) > 0 && length(trimspace(share.system_name)) > 0
    ])
    error_message = "Every Cloud Direct share requires non-empty name and system_name values."
  }
}

variable "sla_ids" {
  description = "Valid Rubrik SLA Domain UUIDs keyed by the configured NAS Cloud Direct share key."
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
