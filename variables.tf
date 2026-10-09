variable "rubrik_graphql_url" {
  description = "Rubrik Security Cloud GraphQL endpoint URL."
  type        = string
}

variable "rubrik_api_token" {
  description = "Bearer token used to authenticate to the Rubrik GraphQL API."
  type        = string
  sensitive   = true
}

variable "vsphere_vm_ids" {
  description = "Rubrik IDs of the vSphere VMs to protect."
  type        = set(string)

  validation {
    condition = alltrue([
      for id in var.vsphere_vm_ids :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "Every vSphere VM ID must be a UUID."
  }
}

variable "vsphere_folder_ids" {
  description = "Rubrik IDs of vSphere folders to assign to the managed SLA Domain."
  type        = set(string)

  validation {
    condition = alltrue([
      for id in var.vsphere_folder_ids :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "Every vSphere folder ID must be a UUID."
  }
}

variable "vsphere_tag_ids" {
  description = "Rubrik IDs of vSphere tags to assign to the managed SLA Domain."
  type        = set(string)

  validation {
    condition = alltrue([
      for id in var.vsphere_tag_ids :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "Every vSphere tag ID must be a UUID."
  }
}

variable "postgresql_db_cluster_ids" {
  description = "Rubrik IDs of PostgreSQL database clusters to protect."
  type        = set(string)

  validation {
    condition = alltrue([
      for id in var.postgresql_db_cluster_ids :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "Every PostgreSQL database cluster ID must be a UUID."
  }
}

variable "nas_share_ids" {
  description = "Rubrik IDs of existing NAS shares to protect."
  type        = set(string)

  validation {
    condition = alltrue([
      for id in var.nas_share_ids :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "Every NAS share ID must be a UUID."
  }
}

variable "sla_domain_name" {
  description = "Name for the Rubrik SLA Domain managed by this configuration."
  type        = string
}

variable "sla_domain_description" {
  description = "Description for the managed SLA Domain."
  type        = string
  default     = null
}

variable "sla_domain_object_types" {
  description = "Object types supported by the managed SLA Domain."
  type        = set(string)

  validation {
    condition     = length(var.sla_domain_object_types) > 0
    error_message = "At least one SLA Domain object type is required."
  }
}

variable "sla_domain_snapshot_schedule" {
  description = "Snapshot schedule passed to Rubrik as a GlobalSnapshotScheduleInput value."
  type        = any
}

variable "service_account_name" {
  description = "Name for the Rubrik automation service account."
  type        = string
}

variable "object_inventory_role_name" {
  description = "Name for the Rubrik role granting account-wide object inventory visibility."
  type        = string
  default     = "Terraform object inventory reader"
}

variable "service_account_description" {
  description = "Description for the Rubrik automation service account."
  type        = string
  default     = ""
}

variable "service_account_role_ids" {
  description = "Rubrik role IDs assigned to the automation service account."
  type        = set(string)
  default     = []
}
