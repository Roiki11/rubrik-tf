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

variable "kubernetes_cluster_names" {
  description = "Exact Rubrik inventory names of Kubernetes clusters to protect."
  type        = set(string)
  default     = []
}

variable "kubernetes_protection_set_names" {
  description = "Exact Rubrik inventory names of Kubernetes protection sets to protect."
  type        = set(string)
  default     = []
}

variable "kubernetes_namespaces" {
  description = "Kubernetes namespaces to protect, keyed by stable Terraform keys and identified by exact cluster and namespace names."
  type = map(object({
    cluster_name   = string
    namespace_name = string
  }))
  default = {}
}

variable "proxmox_objects" {
  description = "Proxmox objects to protect, keyed by stable Terraform keys with each exact Rubrik inventory name and managed-object type."
  type = map(object({
    name        = string
    object_type = string
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
  description = "Rubrik SlaObjectType values supported by the managed SLA Domain, including K8S_OBJECT_TYPE, KUPR_OBJECT_TYPE, and PROXMOX_OBJECT_TYPE when applicable."
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

variable "classification_analyzers" {
  description = "Custom sensitive-data analyzers keyed by stable Terraform names."
  type = map(object({
    name                          = string
    analyzer_type                 = string
    risk                          = string
    rule_types                    = optional(set(string), [])
    dictionary                    = optional(set(string), [])
    dictionary_csv                = optional(string)
    structured_dictionary         = optional(set(string), [])
    regex                         = optional(string)
    key_regex                     = optional(string)
    structured_value_regex        = optional(string)
    structured_dictionary_csv     = optional(string)
    structured_key_dictionary     = optional(set(string), [])
    structured_key_dictionary_csv = optional(string)
    exclude_field_name_pattern    = optional(string)
    exclude_path_pattern          = optional(string)
    exclude_value_regex           = optional(string)
    proximity_distance            = optional(number)
    proximity_keywords_regex      = optional(string)
    tag_id                        = optional(number)
    analyzer_risk_instance = optional(object({
      analyzer_id  = string
      risk         = string
      risk_version = number
    }))
    is_inactive = optional(bool, false)
  }))
  default = {}
}

variable "classification_policies" {
  description = "Sensitive-data classification policies keyed by stable Terraform names."
  type = map(object({
    name              = string
    description       = optional(string, "")
    mode              = optional(string, "DISCOVERY")
    color_enum        = optional(string, "COLOR_006")
    analyzer_ids      = optional(set(string), [])
    analyzer_keys     = optional(set(string), [])
    document_type_ids = optional(set(string), [])
    object_ids        = optional(set(string), [])
    object_root_ids   = optional(set(string), [])
    cluster_ids       = optional(set(string), [])
  }))
  default = {}
}

variable "sensitive_data_discovery_enabled" {
  description = "Whether to query the current sensitive-data summary and data discovery object counts."
  type        = bool
  default     = false
}

variable "sensitive_data_summary_input" {
  description = "SensitiveDataSummaryInput passed to Rubrik when sensitive-data discovery reporting is enabled."
  type        = any
  default     = { includeBreakdown = true }
}

variable "vsphere_servers" {
  description = "vCenter Servers and standalone ESXi hosts to register, keyed by stable Terraform names."
  type = map(object({
    cluster_uuid                          = string
    hostname                              = string
    username                              = string
    password                              = string
    ca_certs                              = optional(string)
    is_standalone_host                    = optional(bool, false)
    should_enable_hot_add_proxy_onprem    = optional(bool, false)
    conflict_resolution_authz             = optional(string, "NoConflictResolution")
    org_network_id                        = optional(string)
    is_compute_visibility_filter_disabled = optional(bool)
  }))
  default   = {}
  sensitive = true
}

variable "proxmox_hosts" {
  description = "Existing Rubrik Proxmox environments to configure, keyed by stable Terraform names."
  type = map(object({
    environment_id = string
    api_token      = optional(string)
    ca_certs       = optional(string)
  }))
  default   = {}
  sensitive = true

  validation {
    condition = alltrue([
      for host in values(var.proxmox_hosts) :
      host.api_token != null || host.ca_certs != null
    ])
    error_message = "Each Proxmox host must configure at least an api_token or ca_certs value."
  }
}

variable "tape_archival_targets" {
  description = "Tape archival targets to create, keyed by stable Terraform names."
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
}

variable "tape_reader_targets" {
  description = "Tape reader archival targets to create, keyed by stable Terraform names."
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
      for target in values(var.tape_reader_targets) :
      contains([
        "OBJECT_LIST_AND_DETAILS",
        "OBJECT_LIST_ONLY",
        "SPECIFIC_OBJECT_LIST_AND_DETAILS",
      ], target.reader_retrieval_method)
    ])
    error_message = "reader_retrieval_method must be OBJECT_LIST_AND_DETAILS, OBJECT_LIST_ONLY, or SPECIFIC_OBJECT_LIST_AND_DETAILS."
  }
}
