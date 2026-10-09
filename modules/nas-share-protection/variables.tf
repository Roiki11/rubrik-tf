variable "share_names" {
  description = "Exact Rubrik inventory names of the existing NAS shares to protect. Each name must resolve to exactly one share."
  type        = set(string)
  default     = []
}

variable "nas_server" {
  description = "Optional NAS server to register. Use NAS_VENDOR_TYPE_GENERIC or NAS_VENDOR_TYPE_ISILON (PowerScale)."
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

  validation {
    condition = var.nas_server == null || contains([
      "NAS_VENDOR_TYPE_GENERIC",
      "NAS_VENDOR_TYPE_ISILON",
    ], var.nas_server.vendor_type)
    error_message = "NAS server vendor_type must be NAS_VENDOR_TYPE_GENERIC or NAS_VENDOR_TYPE_ISILON."
  }

  validation {
    condition = var.nas_server == null || (
      var.nas_server.vendor_type == "NAS_VENDOR_TYPE_GENERIC" ?
      var.nas_server.generic_parameters != null :
      var.nas_server.api_credentials != null
    )
    error_message = "Generic NAS requires generic_parameters; PowerScale requires api_credentials."
  }
}

variable "nas_shares" {
  description = "Optional manually added shares for nas_server, keyed by a stable Terraform name."
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

  validation {
    condition = alltrue([
      for share in values(var.nas_shares) : contains([
        "CREATE_NAS_SHARE_INPUT_SHARE_TYPE_NFS",
        "CREATE_NAS_SHARE_INPUT_SHARE_TYPE_SMB",
      ], share.share_type)
    ])
    error_message = "NAS share share_type must be CREATE_NAS_SHARE_INPUT_SHARE_TYPE_NFS or CREATE_NAS_SHARE_INPUT_SHARE_TYPE_SMB."
  }
}

variable "sla_id" {
  description = "Rubrik ID of the existing SLA Domain to assign to each NAS share."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.sla_id))
    error_message = "The SLA Domain ID must be a UUID."
  }
}
