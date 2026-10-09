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
      length(template.includes) > 0 &&
      alltrue([for path in template.includes : length(trimspace(path)) > 0]) &&
      alltrue([for path in template.excludes : length(trimspace(path)) > 0]) &&
      alltrue([for path in template.exceptions : length(trimspace(path)) > 0])
    ])
    error_message = "Every Linux fileset template must include at least one non-empty path; exclude and exception paths must also be non-empty."
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

variable "sla_ids" {
  description = "Valid Rubrik SLA Domain UUIDs keyed as assignment:<Terraform assignment key>."
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
