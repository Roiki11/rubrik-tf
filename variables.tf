variable "rubrik_graphql_url" {
  description = "Rubrik Security Cloud GraphQL endpoint URL."
  type        = string
}

variable "rubrik_api_token" {
  description = "Bearer token used to authenticate to the Rubrik GraphQL API."
  type        = string
  sensitive   = true
}

variable "vsphere_vm_ids" {
  description = "Rubrik IDs of the vSphere VMs to protect."
  type        = set(string)

  validation {
    condition = alltrue([
      for id in var.vsphere_vm_ids :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", id))
    ])
    error_message = "Every vSphere VM ID must be a UUID."
  }
}

variable "sla_domain_id" {
  description = "Rubrik ID of the existing SLA Domain to assign to each vSphere VM."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.sla_domain_id))
    error_message = "The SLA Domain ID must be a UUID."
  }
}
