variable "hosts" {
  description = "Existing Rubrik Proxmox environment IDs and updated API-token/CA certificate configuration."
  type = map(object({
    environment_id = string
    api_token      = optional(string)
    ca_certs       = optional(string)
  }))
  default   = {}
  sensitive = true

  validation {
    condition = alltrue([
      for host in values(var.hosts) :
      length(trimspace(host.environment_id)) > 0 &&
      (host.api_token != null || host.ca_certs != null) &&
      (host.api_token == null || length(trimspace(host.api_token)) > 0) &&
      (host.ca_certs == null || length(trimspace(host.ca_certs)) > 0)
    ])
    error_message = "Each Proxmox host requires a non-empty environment_id and at least one non-empty api_token or ca_certs value."
  }
}
