variable "cluster_uuid" {
  description = "Rubrik CDM cluster UUID used to create Linux fileset templates and filesets."
  type        = string
  default     = ""
}

variable "fileset_templates" {
  description = "Linux fileset template definitions keyed by their Rubrik template name."
  type = map(object({
    includes                     = set(string)
    excludes                     = optional(set(string), [])
    exceptions                   = optional(set(string), [])
    pre_backup_script            = optional(string)
    post_backup_script           = optional(string)
    backup_script_error_handling = optional(string)
    backup_script_timeout        = optional(number)
    fileset_options = optional(object({
      allow_backup_hidden_folders_in_network_mounts = optional(bool)
      allow_backup_network_mounts                   = optional(bool)
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for template in values(var.fileset_templates) :
      length(template.includes) > 0
    ])
    error_message = "Every Linux fileset template must include at least one path."
  }

  validation {
    condition = alltrue([
      for template in values(var.fileset_templates) :
      template.backup_script_error_handling == null ||
      contains(["abort", "continue"], template.backup_script_error_handling)
    ])
    error_message = "backup_script_error_handling must be abort or continue."
  }
}

variable "fileset_assignments" {
  description = "Linux host and fileset template pairs to create and protect, keyed by a stable Terraform name."
  type = map(object({
    host_name                 = string
    template_name             = string
    enable_hardlink_support   = optional(bool, false)
    enable_symlink_resolution = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for assignment in values(var.fileset_assignments) :
      length(trimspace(assignment.host_name)) > 0 &&
      length(trimspace(assignment.template_name)) > 0
    ])
    error_message = "Each fileset assignment requires a non-empty host_name and template_name."
  }
}

variable "sla_id" {
  description = "Rubrik ID of the existing SLA Domain to assign to each created Linux fileset."
  type        = string
  default     = ""

  validation {
    condition = var.sla_id == "" || can(regex(
      "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$",
      var.sla_id
    ))
    error_message = "The SLA Domain ID must be a UUID when fileset assignments are configured."
  }
}
