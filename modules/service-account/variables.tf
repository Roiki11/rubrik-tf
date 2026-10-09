variable "name" {
  description = "Name of the Rubrik service account."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "The service-account name must be non-empty."
  }
}

variable "description" {
  description = "Description of the Rubrik service account."
  type        = string
  default     = ""
}

variable "role_ids" {
  description = "Rubrik role UUIDs to grant to the service account; provide at least one."
  type        = set(string)

  validation {
    condition = length(var.role_ids) > 0 && alltrue([
      for id in var.role_ids :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "At least one role ID is required, and every role ID must be a UUID in 8-4-4-4-12 hexadecimal format."
  }
}
