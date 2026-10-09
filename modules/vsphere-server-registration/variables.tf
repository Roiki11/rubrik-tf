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
    conflict_resolution_authz             = optional(string, "NoConflictResolution")
    org_network_id                        = optional(string)
    is_compute_visibility_filter_disabled = optional(bool)
  }))
  default   = {}
  sensitive = true

  validation {
    condition = alltrue([
      for server in values(var.servers) :
      contains(["AllowAutoConflictResolution", "NoConflictResolution"], server.conflict_resolution_authz)
    ])
    error_message = "conflict_resolution_authz must be AllowAutoConflictResolution or NoConflictResolution."
  }
}
