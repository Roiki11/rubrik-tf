variable "name" {
  description = "Non-empty name of the SLA Domain."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "The SLA Domain name must be non-empty."
  }
}

variable "description" {
  description = "Optional description of the SLA Domain."
  type        = string
  default     = null
}

variable "object_types" {
  description = "Non-empty Rubrik SlaObjectType enum values supported by this SLA Domain, such as VSPHERE_OBJECT_TYPE, POSTGRES_DB_CLUSTER_OBJECT_TYPE, NAS_OBJECT_TYPE, FILESET_OBJECT_TYPE, K8S_OBJECT_TYPE, KUPR_OBJECT_TYPE, PROXMOX_OBJECT_TYPE, and NCD_OBJECT_TYPE. Accepted values depend on the target Rubrik schema."
  type        = set(string)

  validation {
    condition = length(var.object_types) > 0 && alltrue([
      for object_type in var.object_types : length(trimspace(object_type)) > 0
    ])
    error_message = "At least one non-empty Rubrik SlaObjectType value is required."
  }
}

variable "snapshot_schedule" {
  description = "Rubrik GlobalSnapshotScheduleInput object with one or more of minute, hourly, daily, weekly, monthly, quarterly, and yearly schedules."
  type        = any

  validation {
    condition = can(keys(var.snapshot_schedule)) && length(keys(var.snapshot_schedule)) > 0 && alltrue([
      for cadence in keys(var.snapshot_schedule) :
      contains(["minute", "hourly", "daily", "weekly", "monthly", "quarterly", "yearly"], cadence)
    ])
    error_message = "snapshot_schedule must be an object containing at least one supported cadence: minute, hourly, daily, weekly, monthly, quarterly, or yearly."
  }
}

variable "archival_specs" {
  description = "Optional list of Rubrik ArchivalSpecInput objects defining archival targets, thresholds, frequencies, and related settings; valid fields and enum values depend on the target Rubrik schema."
  type        = list(any)
  default     = []
}
