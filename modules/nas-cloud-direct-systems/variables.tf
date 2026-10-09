variable "systems" {
  description = "NAS Cloud Direct systems to register, keyed by stable Terraform names."
  type = map(object({
    cluster_id                    = string
    host                          = string
    system_type                   = string
    skip_service_account_creation = bool
    verify_ssl                    = bool
    certificate_data              = optional(string)
    certificate_key_password      = optional(string)
    certificate_type              = optional(string)
    creds = optional(list(object({
      name     = string
      username = string
      password = string
    })), [])
    management_info = optional(object({
      file_system_id   = optional(string)
      private_endpoint = optional(string)
    }))
    password = optional(string)
    region   = optional(string)
    username = optional(string)
  }))
  default   = {}
  sensitive = true

  validation {
    condition = alltrue([
      for system in values(var.systems) :
      contains([
        "AZURE_FILES",
        "AZURE_NETAPP",
        "FLASHARRAY",
        "FLASHBLADE",
        "FSXN",
        "GENERIC",
        "GENERIC_NFS",
        "GENERIC_NFS4",
        "GENERIC_S3",
        "GENERIC_SMB",
        "GPFS",
        "ISILON",
        "NETAPP",
        "NETAPP_7_MODE",
        "NETAPP_CLUSTER_MODE",
        "NUTANIX",
        "NUTANIX_FILESERVER",
        "QUMULO",
        "UNSPECIFIED",
        "VAST_DATA",
      ], system.system_type)
    ])
    error_message = "system_type must be a CloudDirectNasVendorType value supported by Rubrik."
  }

  validation {
    condition = alltrue([
      for system in values(var.systems) :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", system.cluster_id)) &&
      length(trimspace(system.host)) > 0
    ])
    error_message = "Every NAS Cloud Direct system requires a valid cluster_id UUID and non-empty host."
  }

  validation {
    condition = alltrue([
      for system in values(var.systems) :
      system.certificate_type == null || contains(["PEM", "PKCS12"], system.certificate_type)
    ])
    error_message = "certificate_type must be PEM or PKCS12."
  }
}
