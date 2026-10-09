variable "rubrik_graphql_url" {
  description = "Rubrik Security Cloud GraphQL endpoint URL."
  type        = string
}

variable "vault_credential_refs" {
  description = "HashiCorp Vault KV v2 credential references keyed by logical credential name."
  type = map(object({
    mount = string
    path  = string
    key   = string
  }))

  validation {
    condition = alltrue([
      for ref in values(var.vault_credential_refs) :
      length(trimspace(ref.mount)) > 0 &&
      length(trimspace(ref.path)) > 0 &&
      length(trimspace(ref.key)) > 0
    ])
    error_message = "Every Vault credential reference must specify a mount, path, and key."
  }
}

/*
variable "rubrik_api_token" {
  description = "Bearer token used to authenticate to the Rubrik GraphQL API."
  type        = string
  sensitive   = true
}
*/

variable "vsphere_vm_names" {
  description = "Exact names of the vSphere VMs to protect. Each name must uniquely resolve in Rubrik."
  type        = set(string)
}

variable "vsphere_vm_sla_domain_keys" {
  description = "SLA Domain keys assigned to vSphere VMs, keyed by exact VM name."
  type        = map(string)
  default     = {}
}

variable "vsphere_folder_names" {
  description = "Exact names of vSphere folders to assign to an SLA Domain. Each name must uniquely resolve in Rubrik."
  type        = set(string)
}

variable "vsphere_folder_sla_domain_keys" {
  description = "SLA Domain keys assigned to vSphere folders, keyed by exact folder name."
  type        = map(string)
  default     = {}
}

variable "vsphere_tag_ids" {
  description = "Rubrik IDs of vSphere tags to assign to an SLA Domain."
  type        = set(string)

  validation {
    condition = alltrue([
      for id in var.vsphere_tag_ids :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "Every vSphere tag ID must be a UUID."
  }
}

variable "vsphere_tag_sla_domain_keys" {
  description = "SLA Domain keys assigned to vSphere tags, keyed by tag UUID."
  type        = map(string)
  default     = {}
}

variable "postgresql_db_cluster_names" {
  description = "Exact names of PostgreSQL database clusters to protect. Each name must uniquely resolve in Rubrik."
  type        = set(string)
}

variable "postgresql_sla_domain_keys" {
  description = "SLA Domain keys assigned to PostgreSQL database clusters, keyed by exact cluster name."
  type        = map(string)
  default     = {}
}

variable "nas_share_names" {
  description = "Exact names of existing NAS shares to protect. Each name must uniquely resolve in Rubrik."
  type        = set(string)
}

variable "nas_share_sla_domain_keys" {
  description = "SLA Domain keys assigned to existing NAS shares, keyed by exact share name."
  type        = map(string)
  default     = {}
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

variable "linux_fileset_sla_domain_keys" {
  description = "SLA Domain keys assigned to Linux fileset assignments, keyed by Terraform assignment key."
  type        = map(string)
  default     = {}
}

variable "kubernetes_cluster_names" {
  description = "Exact Rubrik inventory names of Kubernetes clusters to protect."
  type        = set(string)
  default     = []
}

variable "kubernetes_cluster_sla_domain_keys" {
  description = "SLA Domain keys assigned to Kubernetes clusters, keyed by exact cluster name."
  type        = map(string)
  default     = {}
}

variable "kubernetes_protection_set_names" {
  description = "Exact Rubrik inventory names of Kubernetes protection sets to protect."
  type        = set(string)
  default     = []
}

variable "kubernetes_protection_set_sla_domain_keys" {
  description = "SLA Domain keys assigned to Kubernetes protection sets, keyed by exact protection-set name."
  type        = map(string)
  default     = {}
}

variable "kubernetes_namespaces" {
  description = "Kubernetes namespaces to protect, keyed by stable Terraform keys and identified by exact cluster and namespace names."
  type = map(object({
    cluster_name   = string
    namespace_name = string
  }))
  default = {}
}

variable "kubernetes_namespace_sla_domain_keys" {
  description = "SLA Domain keys assigned to Kubernetes namespaces, keyed by Terraform namespace key."
  type        = map(string)
  default     = {}
}

variable "proxmox_objects" {
  description = "Proxmox objects to protect, keyed by stable Terraform keys with each exact Rubrik inventory name and managed-object type."
  type = map(object({
    name        = string
    object_type = string
  }))
  default = {}
}

variable "proxmox_object_sla_domain_keys" {
  description = "SLA Domain keys assigned to Proxmox objects, keyed by Terraform object key."
  type        = map(string)
  default     = {}
}

variable "nas_servers" {
  description = "Generic NAS and PowerScale (Isilon) servers to register, keyed by stable Terraform names."
  type = map(object({
    cluster_uuid = string
    hostname     = string
    vendor_type  = string
    generic_parameters = optional(object({
      has_nfs_support      = bool
      has_smb_support      = bool
      nfs_pseudo_fs_prefix = optional(string)
      smb_credentials = optional(object({
        username_credential = string
        password_credential = string
      }))
    }))
    api_credentials = optional(object({
      api_username_credential    = string
      api_password_credential    = string
      api_certificate_credential = optional(string)
      certificate_id             = optional(string)
    }))
    smb_credentials = optional(object({
      username_credential = string
      password_credential = string
    }))
    is_isilon_changelist_enabled = optional(bool)
  }))
  default = {}
  validation {
    condition = alltrue([
      for server in values(var.nas_servers) : contains([
        "NAS_VENDOR_TYPE_GENERIC",
        "NAS_VENDOR_TYPE_ISILON",
      ], server.vendor_type)
    ])
    error_message = "NAS server vendor_type must be NAS_VENDOR_TYPE_GENERIC or NAS_VENDOR_TYPE_ISILON."
  }

  validation {
    condition = alltrue([
      for server in values(var.nas_servers) :
      server.vendor_type == "NAS_VENDOR_TYPE_GENERIC" ?
      server.generic_parameters != null :
      server.api_credentials != null
    ])
    error_message = "Generic NAS requires generic_parameters; PowerScale requires api_credentials."
  }
}

variable "nas_shares" {
  description = "Optional manually added NAS share configuration, keyed by stable Terraform names."
  type = map(object({
    export_point   = string
    share_type     = string
    nas_server_key = string
    credentials = optional(object({
      username_credential = string
      password_credential = optional(string)
    }))
  }))
  default = {}
}

variable "nas_configured_share_sla_domain_keys" {
  description = "SLA Domain keys assigned to manually added NAS shares, keyed by Terraform share key."
  type        = map(string)
  default     = {}
}

variable "nas_cloud_direct_systems" {
  description = "NAS Cloud Direct systems to register, keyed by stable Terraform names."
  type = map(object({
    cluster_id                          = string
    host                                = string
    system_type                         = string
    skip_service_account_creation       = bool
    verify_ssl                          = bool
    certificate_data_credential         = optional(string)
    certificate_key_password_credential = optional(string)
    certificate_type                    = optional(string)
    creds = optional(list(object({
      name                = string
      username_credential = string
      password_credential = string
    })), [])
    management_info = optional(object({
      file_system_id   = optional(string)
      private_endpoint = optional(string)
    }))
    password_credential = optional(string)
    region              = optional(string)
    username_credential = optional(string)
  }))
  default = {}
}

variable "nas_cloud_direct_shares" {
  description = "Existing NAS Cloud Direct shares to protect, keyed by stable Terraform names and identified by exact share and system names."
  type = map(object({
    name        = string
    system_name = string
  }))
  default = {}
}

variable "nas_cloud_direct_share_sla_domain_keys" {
  description = "SLA Domain keys assigned to NAS Cloud Direct shares, keyed by Terraform share key."
  type        = map(string)
  default     = {}
}

variable "sla_domains" {
  description = "SLA Domains to manage, keyed by stable Terraform names."
  type        = any

  validation {
    condition     = length(var.sla_domains) > 0
    error_message = "At least one SLA Domain must be configured."
  }

  validation {
    condition = alltrue([
      for sla in values(var.sla_domains) :
      can(sla.name) && can(sla.object_types) && can(sla.snapshot_schedule)
    ])
    error_message = "Every SLA Domain must include name, object_types, and snapshot_schedule."
  }

  validation {
    condition = alltrue([
      for sla in values(var.sla_domains) :
      length(trimspace(sla.name)) > 0 && length(sla.object_types) > 0
    ])
    error_message = "Every SLA Domain must have a non-empty name and at least one object type."
  }
}

variable "object_inventory_roles" {
  description = "Account-wide object inventory roles to manage, keyed by stable Terraform names."
  type = map(object({
    name        = string
    description = optional(string, "Account-wide read-only access to protectable object inventory.")
  }))
  default = {}
}

variable "service_accounts" {
  description = "Rubrik automation service accounts to manage, keyed by stable Terraform names."
  type = map(object({
    name                = string
    description         = optional(string, "")
    role_ids            = optional(set(string), [])
    inventory_role_keys = optional(set(string), [])
  }))
  default = {}
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
    username_credential                   = string
    password_credential                   = string
    ca_certs_credential                   = optional(string)
    is_standalone_host                    = optional(bool, false)
    should_enable_hot_add_proxy_onprem    = optional(bool, false)
    conflict_resolution_authz             = optional(string, "VCENTER_CONFIG_V2_CONFLICT_RESOLUTION_AUTHZ_NO_CONFLICT_RESOLUTION")
    org_network_id                        = optional(string)
    is_compute_visibility_filter_disabled = optional(bool)
  }))
  default = {}
}

variable "proxmox_hosts" {
  description = "Existing Rubrik Proxmox environments to configure, keyed by stable Terraform names."
  type = map(object({
    environment_id       = string
    api_token_credential = optional(string)
    ca_certs_credential  = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for host in values(var.proxmox_hosts) :
      host.api_token_credential != null || host.ca_certs_credential != null
    ])
    error_message = "Each Proxmox host must configure at least an api_token or ca_certs value."
  }
}

variable "tape_archival_targets" {
  description = "Tape archival targets to create, keyed by stable Terraform names."
  type = map(object({
    cluster_uuid                   = string
    destination_folder_name        = string
    encryption_password_credential = string
    host_name                      = string
    host_port                      = number
    integral_volume_name           = string
    name                           = string
    password_credential            = string
    username_credential            = string
  }))
  default = {}
}

variable "tape_reader_targets" {
  description = "Tape reader archival targets to create, keyed by stable Terraform names."
  type = map(object({
    archival_data_source_ids       = optional(set(string), [])
    cluster_uuid                   = string
    destination_folder_name        = string
    encryption_password_credential = string
    host_name                      = string
    host_port                      = number
    integral_volume_name           = string
    name                           = string
    password_credential            = string
    reader_retrieval_method        = string
    username_credential            = string
  }))
  default = {}

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
