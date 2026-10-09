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
      host.api_token != null || host.ca_certs != null
    ])
    error_message = "Each Proxmox host must configure at least an api_token or ca_certs value."
  }
}
