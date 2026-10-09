variable "name" {
  description = "Name of the Rubrik service account."
  type        = string
}

variable "description" {
  description = "Description of the Rubrik service account."
  type        = string
  default     = ""
}

variable "role_ids" {
  description = "Rubrik role IDs to grant to the service account."
  type        = set(string)

  validation {
    condition     = length(var.role_ids) > 0
    error_message = "At least one role ID is required."
  }
}
