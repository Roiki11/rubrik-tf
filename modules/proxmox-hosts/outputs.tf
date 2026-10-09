output "host_states" {
  description = "Proxmox environment details returned by Rubrik."
  value = {
    for key, host in graphql_mutation.host :
    key => jsondecode(host.query_response).data.hierarchyObjects[0]
  }
}

output "environment_ids" {
  description = "Map of configured Terraform keys to their Rubrik Proxmox environment IDs."
  value       = { for key, host in var.hosts : key => host.environment_id }
}
