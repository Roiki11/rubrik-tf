variable "share_names" {
  description = "Exact, non-empty Rubrik inventory names of existing NAS shares to protect. Each name must resolve to exactly one share."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for name in var.share_names : length(trimspace(name)) > 0])
    error_message = "Every existing NAS share name must be non-empty."
  }
}

variable "nas_servers" {
  description = "NAS servers to register, keyed by stable Terraform names."
  type = map(object({
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
  }))
  default   = {}
  sensitive = true

  validation {
    condition = alltrue([
      for server in values(var.nas_servers) :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", server.cluster_uuid)) &&
      length(trimspace(server.hostname)) > 0 &&
      contains(["NAS_VENDOR_TYPE_GENERIC", "NAS_VENDOR_TYPE_ISILON"], server.vendor_type)
    ])
    error_message = "Each NAS server requires a UUID cluster_uuid, non-empty hostname, and vendor_type NAS_VENDOR_TYPE_GENERIC or NAS_VENDOR_TYPE_ISILON."
  }

  validation {
    condition = alltrue([
      for server in values(var.nas_servers) :
      server.vendor_type == "NAS_VENDOR_TYPE_GENERIC" ?
      server.generic_parameters != null :
      server.api_credentials != null &&
      length(trimspace(server.api_credentials.api_username)) > 0 &&
      length(trimspace(server.api_credentials.api_password)) > 0
    ])
    error_message = "Generic NAS requires generic_parameters; PowerScale requires non-empty API credentials."
  }
}

variable "nas_shares" {
  description = "Optional manually added shares for nas_server, keyed by a stable Terraform name."
  type = map(object({
    export_point   = string
    share_type     = string
    nas_server_key = string
    credentials = optional(object({
      username = string
      password = optional(string)
    }))
  }))
  default   = {}
  sensitive = true

  validation {
    condition = alltrue([
      for share in values(var.nas_shares) :
      length(trimspace(share.export_point)) > 0 &&
      length(trimspace(share.nas_server_key)) > 0 &&
      contains(["CREATE_NAS_SHARE_INPUT_SHARE_TYPE_NFS", "CREATE_NAS_SHARE_INPUT_SHARE_TYPE_SMB"], share.share_type)
    ])
    error_message = "Every NAS share requires non-empty export_point and nas_server_key values; share_type must be CREATE_NAS_SHARE_INPUT_SHARE_TYPE_NFS or CREATE_NAS_SHARE_INPUT_SHARE_TYPE_SMB."
  }
}

variable "sla_ids" {
  description = "Valid Rubrik SLA Domain UUIDs keyed as existing:<share name> or configured:<share key>."
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for id in values(var.sla_ids) :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "Every SLA ID must be a UUID in 8-4-4-4-12 hexadecimal format."
  }
}
