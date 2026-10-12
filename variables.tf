variable "rubrik_graphql_url" {
  description = "Rubrik Security Cloud GraphQL endpoint URL."
  type        = string

  validation {
    condition     = can(regex("^https://[^[:space:]]+$", var.rubrik_graphql_url))
    error_message = "rubrik_graphql_url must be a non-empty HTTPS URL."
  }
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

  validation {
    condition     = length(var.vault_credential_refs) > 0 && contains(keys(var.vault_credential_refs), "rubrik_api_token")
    error_message = "vault_credential_refs must include the rubrik_api_token credential alias."
  }
}

variable "vsphere_vms" {
  description = "Exact vSphere VM names mapped to the SLA Domain key to assign."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for name, sla_key in var.vsphere_vms :
      length(trimspace(name)) > 0 && length(trimspace(sla_key)) > 0
    ])
    error_message = "Every vSphere VM name and sla_domain_key must be non-empty."
  }
}

variable "vsphere_folders" {
  description = "Exact vSphere folder names mapped to the SLA Domain key to assign."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for name, sla_key in var.vsphere_folders :
      length(trimspace(name)) > 0 && length(trimspace(sla_key)) > 0
    ])
    error_message = "Every vSphere folder name and sla_domain_key must be non-empty."
  }
}

variable "vsphere_tags" {
  description = "Rubrik vSphere tag UUIDs mapped to the SLA Domain key to assign."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for id in keys(var.vsphere_tags) :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "Every vSphere tag ID must be a UUID."
  }

  validation {
    condition = alltrue([
      for sla_key in values(var.vsphere_tags) : length(trimspace(sla_key)) > 0
    ])
    error_message = "Every vSphere tag must have a non-empty sla_domain_key."
  }
}

variable "postgresql_clusters" {
  description = "Exact PostgreSQL cluster names mapped to the SLA Domain key to assign."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for name, sla_key in var.postgresql_clusters :
      length(trimspace(name)) > 0 && length(trimspace(sla_key)) > 0
    ])
    error_message = "Every PostgreSQL cluster name and sla_domain_key must be non-empty."
  }
}

variable "nas_existing_shares" {
  description = "Exact existing NAS share names mapped to the SLA Domain key to assign."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for name, sla_key in var.nas_existing_shares :
      length(trimspace(name)) > 0 && length(trimspace(sla_key)) > 0
    ])
    error_message = "Every existing NAS share name and sla_domain_key must be non-empty."
  }
}

variable "linux_fileset_cluster_name" {
  description = "Exact Rubrik CDM cluster name used for Linux fileset template and fileset operations."
  type        = string
  default     = ""

  validation {
    condition = (
      length(var.linux_fileset_templates) == 0 &&
      length(var.linux_fileset_assignments) == 0
    ) || length(trimspace(var.linux_fileset_cluster_name)) > 0
    error_message = "linux_fileset_cluster_name is required when Linux fileset templates or assignments are configured."
  }
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
    sla_domain_key            = string
    enable_hardlink_support   = optional(bool, false)
    enable_symlink_resolution = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for assignment in values(var.linux_fileset_assignments) :
      length(trimspace(assignment.host_name)) > 0 &&
      length(trimspace(assignment.template_name)) > 0 &&
      length(trimspace(assignment.sla_domain_key)) > 0
    ])
    error_message = "Each Linux fileset assignment requires non-empty host_name, template_name, and sla_domain_key values."
  }
}

variable "kubernetes" {
  description = "Kubernetes clusters, protection sets, and namespaces to protect, grouped with their SLA Domain keys."
  type = object({
    clusters        = optional(map(string), {})
    protection_sets = optional(map(string), {})
    namespaces = optional(map(object({
      cluster_name   = string
      namespace_name = string
      sla_domain_key = string
    })), {})
  })
  default = {}

  validation {
    condition = alltrue([
      for name, sla_key in var.kubernetes.clusters :
      length(trimspace(name)) > 0 && length(trimspace(sla_key)) > 0
      ]) && alltrue([
      for name, sla_key in var.kubernetes.protection_sets :
      length(trimspace(name)) > 0 && length(trimspace(sla_key)) > 0
      ]) && alltrue([
      for namespace in values(var.kubernetes.namespaces) :
      length(trimspace(namespace.cluster_name)) > 0 &&
      length(trimspace(namespace.namespace_name)) > 0 &&
      length(trimspace(namespace.sla_domain_key)) > 0
    ])
    error_message = "Kubernetes names and sla_domain_key values must be non-empty."
  }
}

variable "proxmox_objects" {
  description = "Proxmox objects to protect, keyed by stable Terraform keys with each exact Rubrik inventory name and managed-object type."
  type = map(object({
    name           = string
    object_type    = string
    sla_domain_key = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for object in values(var.proxmox_objects) :
      length(trimspace(object.name)) > 0 &&
      length(trimspace(object.sla_domain_key)) > 0 &&
      contains(["PROXMOX_ENVIRONMENT", "PROXMOX_CLUSTER", "PROXMOX_NODE", "PROXMOX_VIRTUAL_MACHINE"], object.object_type)
    ])
    error_message = "Each Proxmox object requires a non-empty name and sla_domain_key; object_type must be PROXMOX_ENVIRONMENT, PROXMOX_CLUSTER, PROXMOX_NODE, or PROXMOX_VIRTUAL_MACHINE."
  }
}

variable "nas_servers" {
  description = "Generic NAS and PowerScale (Isilon) servers to register, keyed by stable Terraform names."
  type = map(object({
    cluster_name = string
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
      for server in values(var.nas_servers) :
      length(trimspace(server.cluster_name)) > 0 &&
      length(trimspace(server.hostname)) > 0
    ])
    error_message = "Every NAS server requires a non-empty cluster_name and hostname."
  }

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

  validation {
    condition = alltrue([
      for server in values(var.nas_servers) :
      (server.generic_parameters == null || server.generic_parameters.smb_credentials == null || (
        length(trimspace(server.generic_parameters.smb_credentials.username_credential)) > 0 &&
        length(trimspace(server.generic_parameters.smb_credentials.password_credential)) > 0
      )) &&
      (server.smb_credentials == null || (
        length(trimspace(server.smb_credentials.username_credential)) > 0 &&
        length(trimspace(server.smb_credentials.password_credential)) > 0
      )) &&
      (server.api_credentials == null || (
        length(trimspace(server.api_credentials.api_username_credential)) > 0 &&
        length(trimspace(server.api_credentials.api_password_credential)) > 0 &&
        (server.api_credentials.api_certificate_credential == null || length(trimspace(server.api_credentials.api_certificate_credential)) > 0)
      ))
    ])
    error_message = "NAS credential aliases, when configured, must be non-empty."
  }
}

variable "nas_shares" {
  description = "Optional manually added NAS share configuration, keyed by stable Terraform names."
  type = map(object({
    export_point   = string
    share_type     = string
    nas_server_key = string
    sla_domain_key = string
    credentials = optional(object({
      username_credential = string
      password_credential = optional(string)
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for share in values(var.nas_shares) :
      length(trimspace(share.export_point)) > 0 &&
      length(trimspace(share.nas_server_key)) > 0 &&
      length(trimspace(share.sla_domain_key)) > 0 &&
      contains([
        "CREATE_NAS_SHARE_INPUT_SHARE_TYPE_NFS",
        "CREATE_NAS_SHARE_INPUT_SHARE_TYPE_SMB",
      ], share.share_type) &&
      (share.credentials == null || length(trimspace(share.credentials.username_credential)) > 0) &&
      (share.credentials == null || share.credentials.password_credential == null || length(trimspace(share.credentials.password_credential)) > 0)
    ])
    error_message = "Every NAS share requires non-empty export_point, nas_server_key, and sla_domain_key values; share_type must be CREATE_NAS_SHARE_INPUT_SHARE_TYPE_NFS or CREATE_NAS_SHARE_INPUT_SHARE_TYPE_SMB, and credential aliases must be non-empty."
  }
}

variable "nas_cloud_direct_systems" {
  description = "NAS Cloud Direct systems to register, keyed by stable Terraform names. system_type must be a Rubrik CloudDirectNasVendorType value; certificate_type, when set, must be PEM or PKCS12."
  type = map(object({
    cluster_name                        = string
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

  validation {
    condition = alltrue([
      for system in values(var.nas_cloud_direct_systems) :
      length(trimspace(system.cluster_name)) > 0 &&
      length(trimspace(system.host)) > 0 &&
      (system.certificate_type == null || contains(["PEM", "PKCS12"], system.certificate_type)) &&
      (system.username_credential == null || length(trimspace(system.username_credential)) > 0) &&
      (system.password_credential == null || length(trimspace(system.password_credential)) > 0) &&
      (system.certificate_data_credential == null || length(trimspace(system.certificate_data_credential)) > 0) &&
      (system.certificate_key_password_credential == null || length(trimspace(system.certificate_key_password_credential)) > 0) &&
      alltrue([
        for credential in system.creds :
        length(trimspace(credential.name)) > 0 &&
        length(trimspace(credential.username_credential)) > 0 &&
        length(trimspace(credential.password_credential)) > 0
      ])
    ])
    error_message = "NAS Cloud Direct systems require a non-empty cluster_name, host and named credential fields, and certificate_type null, PEM, or PKCS12."
  }
}

variable "nas_cloud_direct_shares" {
  description = "Existing NAS Cloud Direct shares to protect, keyed by stable Terraform names and identified by exact share and system names."
  type = map(object({
    name           = string
    system_name    = string
    sla_domain_key = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for share in values(var.nas_cloud_direct_shares) :
      length(trimspace(share.name)) > 0 &&
      length(trimspace(share.system_name)) > 0 &&
      length(trimspace(share.sla_domain_key)) > 0
    ])
    error_message = "Every NAS Cloud Direct share requires non-empty name, system_name, and sla_domain_key values."
  }
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
      length(trimspace(sla.name)) > 0 &&
      length(sla.object_types) > 0 &&
      alltrue([for object_type in sla.object_types : length(trimspace(object_type)) > 0])
    ])
    error_message = "Every SLA Domain must have a non-empty name and at least one non-empty Rubrik SlaObjectType enum value."
  }
}

variable "object_inventory_roles" {
  description = "Account-wide object inventory roles to manage, keyed by stable Terraform names."
  type = map(object({
    name        = string
    description = optional(string, "Account-wide read-only access to protectable object inventory.")
  }))
  default = {}

  validation {
    condition     = alltrue([for role in values(var.object_inventory_roles) : length(trimspace(role.name)) > 0])
    error_message = "Every object inventory role requires a non-empty name."
  }
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

  validation {
    condition     = alltrue([for account in values(var.service_accounts) : length(trimspace(account.name)) > 0])
    error_message = "Every service account requires a non-empty name."
  }
}

variable "classification_analyzers" {
  description = "Custom sensitive-data analyzers keyed by stable Terraform names. risk must be HIGH_RISK, MEDIUM_RISK, LOW_RISK, NO_RISK, or UNKNOWN_RISK; rule_types accepts STRUCTURED and UNSTRUCTURED."
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

  validation {
    condition = alltrue([
      for analyzer in values(var.classification_analyzers) :
      length(trimspace(analyzer.name)) > 0 &&
      length(trimspace(analyzer.analyzer_type)) > 0 &&
      contains(["HIGH_RISK", "MEDIUM_RISK", "LOW_RISK", "NO_RISK", "UNKNOWN_RISK"], analyzer.risk) &&
      alltrue([for rule_type in analyzer.rule_types : contains(["STRUCTURED", "UNSTRUCTURED"], rule_type)]) &&
      (analyzer.proximity_distance == null || analyzer.proximity_distance >= 0) &&
      (analyzer.tag_id == null || analyzer.tag_id >= 0) &&
      (analyzer.analyzer_risk_instance == null || contains(["HIGH_RISK", "MEDIUM_RISK", "LOW_RISK", "NO_RISK", "UNKNOWN_RISK"], analyzer.analyzer_risk_instance.risk))
    ])
    error_message = "Analyzers require non-empty name and analyzer_type values; risk values must be HIGH_RISK, MEDIUM_RISK, LOW_RISK, NO_RISK, or UNKNOWN_RISK; rule_types may contain STRUCTURED and/or UNSTRUCTURED; proximity_distance and tag_id must be non-negative."
  }
}

variable "classification_policies" {
  description = "Sensitive-data classification policies keyed by stable Terraform names. mode must be DISCOVERY or COMPLIANCE; color_enum must be a Rubrik ClassificationPolicyColor enum value."
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

  validation {
    condition = alltrue([
      for policy in values(var.classification_policies) :
      length(trimspace(policy.name)) > 0 &&
      contains(["DISCOVERY", "COMPLIANCE"], policy.mode)
    ])
    error_message = "Every classification policy requires a non-empty name and mode DISCOVERY or COMPLIANCE."
  }
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
    cluster_name                          = string
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

  validation {
    condition = alltrue([
      for server in values(var.vsphere_servers) :
      length(trimspace(server.cluster_name)) > 0 &&
      length(trimspace(server.hostname)) > 0 &&
      length(trimspace(server.username_credential)) > 0 &&
      length(trimspace(server.password_credential)) > 0 &&
      contains([
        "VCENTER_CONFIG_V2_CONFLICT_RESOLUTION_AUTHZ_ALLOW_AUTO_CONFLICT_RESOLUTION",
        "VCENTER_CONFIG_V2_CONFLICT_RESOLUTION_AUTHZ_NO_CONFLICT_RESOLUTION",
      ], server.conflict_resolution_authz)
    ])
    error_message = "Each vSphere registration requires a non-empty cluster_name, hostname and credential aliases, and a supported conflict_resolution_authz value."
  }
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
      length(trimspace(host.environment_id)) > 0 &&
      (host.api_token_credential != null || host.ca_certs_credential != null) &&
      (host.api_token_credential == null || length(trimspace(host.api_token_credential)) > 0) &&
      (host.ca_certs_credential == null || length(trimspace(host.ca_certs_credential)) > 0)
    ])
    error_message = "Each Proxmox host requires a non-empty environment_id and at least one non-empty api_token_credential or ca_certs_credential alias."
  }
}

variable "tape_archival_targets" {
  description = "Tape archival targets to create, keyed by stable Terraform names."
  type = map(object({
    cluster_name                   = string
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

  validation {
    condition = alltrue([
      for target in values(var.tape_archival_targets) :
      length(trimspace(target.cluster_name)) > 0 &&
      target.host_port >= 1 && target.host_port <= 65535 && target.host_port == floor(target.host_port) &&
      length(trimspace(target.destination_folder_name)) > 0 &&
      length(trimspace(target.host_name)) > 0 &&
      length(trimspace(target.integral_volume_name)) > 0 &&
      length(trimspace(target.name)) > 0 &&
      length(trimspace(target.encryption_password_credential)) > 0 &&
      length(trimspace(target.password_credential)) > 0 &&
      length(trimspace(target.username_credential)) > 0
    ])
    error_message = "Each tape target requires a non-empty cluster_name, host_port from 1 to 65535, non-empty names, and non-empty credential aliases."
  }
}

variable "tape_reader_targets" {
  description = "Tape reader archival targets to create, keyed by stable Terraform names. reader_retrieval_method must be OBJECT_LIST_AND_DETAILS, OBJECT_LIST_ONLY, or SPECIFIC_OBJECT_LIST_AND_DETAILS."
  type = map(object({
    archival_data_source_ids       = optional(set(string), [])
    cluster_name                   = string
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

  validation {
    condition = alltrue([
      for target in values(var.tape_reader_targets) :
      length(trimspace(target.cluster_name)) > 0 &&
      target.host_port >= 1 && target.host_port <= 65535 &&
      target.host_port == floor(target.host_port) &&
      length(trimspace(target.destination_folder_name)) > 0 &&
      length(trimspace(target.host_name)) > 0 &&
      length(trimspace(target.integral_volume_name)) > 0 &&
      length(trimspace(target.name)) > 0 &&
      length(trimspace(target.encryption_password_credential)) > 0 &&
      length(trimspace(target.password_credential)) > 0 &&
      length(trimspace(target.username_credential)) > 0
    ])
    error_message = "Each tape reader target requires a non-empty cluster_name, host_port from 1 to 65535, non-empty names, and non-empty credential aliases."
  }

  validation {
    condition = alltrue([
      for target in values(var.tape_reader_targets) :
      alltrue([
        for id in target.archival_data_source_ids :
        can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
      ])
    ])
    error_message = "Every archival_data_source_id must be a UUID in 8-4-4-4-12 hexadecimal format."
  }
}
