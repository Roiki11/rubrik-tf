variable "targets" {
  description = "Tape archival targets keyed by stable Terraform names."
  type = map(object({
    cluster_uuid            = string
    destination_folder_name = string
    encryption_password     = string
    host_name               = string
    host_port               = number
    integral_volume_name    = string
    name                    = string
    password                = string
    username                = string
  }))
  default   = {}
  sensitive = true

  validation {
    condition = alltrue([
      for target in values(var.targets) :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", target.cluster_uuid))
      && target.host_port >= 1 && target.host_port <= 65535 && target.host_port == floor(target.host_port)
      && length(trimspace(target.destination_folder_name)) > 0
      && length(trimspace(target.host_name)) > 0
      && length(trimspace(target.integral_volume_name)) > 0
      && length(trimspace(target.name)) > 0
      && length(trimspace(target.username)) > 0
      && length(trimspace(target.password)) > 0
      && length(trimspace(target.encryption_password)) > 0
    ])
    error_message = "Every tape target requires a UUID cluster_uuid, host_port from 1 to 65535, and non-empty destination, host, volume, name, and credential values."
  }
}

variable "reader_targets" {
  description = "Tape reader archival targets keyed by stable Terraform names."
  type = map(object({
    archival_data_source_ids = optional(set(string), [])
    cluster_uuid             = string
    destination_folder_name  = string
    encryption_password      = string
    host_name                = string
    host_port                = number
    integral_volume_name     = string
    name                     = string
    password                 = string
    reader_retrieval_method  = string
    username                 = string
  }))
  default   = {}
  sensitive = true

  validation {
    condition = alltrue([
      for target in values(var.reader_targets) :
      contains([
        "OBJECT_LIST_AND_DETAILS",
        "OBJECT_LIST_ONLY",
        "SPECIFIC_OBJECT_LIST_AND_DETAILS",
      ], target.reader_retrieval_method)
    ])
    error_message = "reader_retrieval_method must be OBJECT_LIST_AND_DETAILS, OBJECT_LIST_ONLY, or SPECIFIC_OBJECT_LIST_AND_DETAILS."
  }

  validation {
    condition = alltrue([
      for target in values(var.reader_targets) :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", target.cluster_uuid))
      && target.host_port >= 1 && target.host_port <= 65535 && target.host_port == floor(target.host_port)
      && length(trimspace(target.destination_folder_name)) > 0
      && length(trimspace(target.host_name)) > 0
      && length(trimspace(target.integral_volume_name)) > 0
      && length(trimspace(target.name)) > 0
      && length(trimspace(target.username)) > 0
      && length(trimspace(target.password)) > 0
      && length(trimspace(target.encryption_password)) > 0
    ])
    error_message = "Every tape reader target requires a UUID cluster_uuid, host_port from 1 to 65535, and non-empty destination, host, volume, name, and credential values."
  }

  validation {
    condition = alltrue([
      for target in values(var.reader_targets) :
      alltrue([
        for id in target.archival_data_source_ids :
        can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
      ])
    ])
    error_message = "Every archival_data_source_id must be a UUID in 8-4-4-4-12 hexadecimal format."
  }
}
