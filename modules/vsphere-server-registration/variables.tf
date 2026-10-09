variable "servers" {
  description = "vCenter servers or standalone ESXi hosts to register, keyed by stable Terraform names."
  type = map(object({
    cluster_uuid                          = string
    hostname                              = string
    username                              = string
    password                              = string
    ca_certs                              = optional(string)
    is_standalone_host                    = optional(bool, false)
    should_enable_hot_add_proxy_onprem    = optional(bool, false)
    conflict_resolution_authz             = optional(string, "VCENTER_CONFIG_V2_CONFLICT_RESOLUTION_AUTHZ_NO_CONFLICT_RESOLUTION")
    org_network_id                        = optional(string)
    is_compute_visibility_filter_disabled = optional(bool)
  }))
  default   = {}
  sensitive = true

  validation {
    condition = alltrue([
      for server in values(var.servers) :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", server.cluster_uuid)) &&
      length(trimspace(server.hostname)) > 0 &&
      length(trimspace(server.username)) > 0 &&
      length(trimspace(server.password)) > 0 &&
      contains([
        "VCENTER_CONFIG_V2_CONFLICT_RESOLUTION_AUTHZ_ALLOW_AUTO_CONFLICT_RESOLUTION",
        "VCENTER_CONFIG_V2_CONFLICT_RESOLUTION_AUTHZ_NO_CONFLICT_RESOLUTION",
      ], server.conflict_resolution_authz)
    ])
    error_message = "Every server requires a UUID cluster_uuid, non-empty hostname/credentials, and conflict_resolution_authz of VCENTER_CONFIG_V2_CONFLICT_RESOLUTION_AUTHZ_ALLOW_AUTO_CONFLICT_RESOLUTION or VCENTER_CONFIG_V2_CONFLICT_RESOLUTION_AUTHZ_NO_CONFLICT_RESOLUTION."
  }
}
