variable "name" {
  description = "Name of the SLA Domain."
  type        = string
}

variable "description" {
  description = "Optional description of the SLA Domain."
  type        = string
  default     = null
}

variable "object_types" {
  description = "Rubrik SlaObjectType enum values supported by this SLA Domain, such as VSphereVm, PostgreSQLDbCluster, K8S_OBJECT_TYPE, KUPR_OBJECT_TYPE, or PROXMOX_OBJECT_TYPE."
  type        = set(string)

  validation {
    condition     = length(var.object_types) > 0
    error_message = "At least one Rubrik object type is required."
  }
}

variable "snapshot_schedule" {
  description = "Rubrik GlobalSnapshotScheduleInput object with optional minute, hourly, daily, weekly, monthly, quarterly, and yearly schedules."
  type        = any
}

variable "archival_specs" {
  description = "Optional list of Rubrik ArchivalSpecInput objects defining archival targets, thresholds, frequencies, and related settings."
  type        = list(any)
  default     = []
}
