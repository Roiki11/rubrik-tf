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
    ])
    error_message = "Every tape target cluster_uuid must be a UUID."
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
    ])
    error_message = "Every tape reader target cluster_uuid must be a UUID."
  }
}
