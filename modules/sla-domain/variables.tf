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
  description = "Rubrik object types supported by this SLA Domain, such as VSphereVm or PostgreSQLDbCluster."
  type        = set(string)

  validation {
    condition     = length(var.object_types) > 0
    error_message = "At least one Rubrik object type is required."
  }
}

variable "snapshot_schedule" {
  description = "Rubrik GlobalSnapshotScheduleInput object describing the snapshot schedule."
  type        = any
}
