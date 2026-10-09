variable "rubrik_graphql_url" {
  description = "Rubrik Security Cloud GraphQL endpoint URL."
  type        = string
}

variable "rubrik_api_token" {
  description = "Bearer token used to authenticate to the Rubrik GraphQL API."
  type        = string
  sensitive   = true
}

variable "vsphere_vm_names" {
  description = "Exact names of the vSphere VMs to protect. Each name must uniquely resolve in Rubrik."
  type        = set(string)
}

variable "vsphere_folder_names" {
  description = "Exact names of vSphere folders to assign to the managed SLA Domain. Each name must uniquely resolve in Rubrik."
  type        = set(string)
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

variable "postgresql_db_cluster_names" {
  description = "Exact names of PostgreSQL database clusters to protect. Each name must uniquely resolve in Rubrik."
  type        = set(string)
}

variable "nas_share_names" {
  description = "Exact names of existing NAS shares to protect. Each name must uniquely resolve in Rubrik."
  type        = set(string)
}

variable "linux_fileset_cluster_uuid" {
  description = "Rubrik CDM cluster UUID used for Linux fileset template and fileset operations."
  type        = string
  default     = ""
}

variable "linux_fileset_templates" {
  description = "Linux fileset templates keyed by name, including include and exclude path configuration."
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
}

variable "linux_fileset_assignments" {
  description = "Linux host and fileset template pairs to create and protect, keyed by a stable Terraform name."
  type = map(object({
    host_name                 = string
    template_name             = string
    enable_hardlink_support   = optional(bool, false)
    enable_symlink_resolution = optional(bool, false)
  }))
  default = {}
}

variable "nas_server" {
  description = "Optional Generic NAS or PowerScale (Isilon) server configuration to register in Rubrik."
  type = object({
    cluster_uuid = string
    hostname     = string
    vendor_type  = string
    generic_parameters = optional(object({
      has_nfs_support      = bool
      has_smb_support      = bool
      nfs_pseudo_fs_prefix = optional(string)
      smb_credentials = optional(object({
        username = string
        password = string
      }))
    }))
    api_credentials = optional(object({
      api_username    = string
      api_password    = string
      api_certificate = optional(string)
      certificate_id  = optional(string)
    }))
    smb_credentials = optional(object({
      username = string
      password = string
    }))
    is_isilon_changelist_enabled = optional(bool)
  })
  default   = null
  sensitive = true
}

variable "nas_shares" {
  description = "Optional manually added NAS share configuration, keyed by stable Terraform names."
  type = map(object({
    export_point = string
    share_type   = string
    credentials = optional(object({
      username = string
      password = optional(string)
    }))
  }))
  default   = {}
  sensitive = true
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
  description = "Snapshot schedule passed to Rubrik as a GlobalSnapshotScheduleInput value, including minute through yearly cadences."
  type        = any
}

variable "sla_domain_archival_specs" {
  description = "Optional archival specifications passed to Rubrik as ArchivalSpecInput values."
  type        = list(any)
  default     = []
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
