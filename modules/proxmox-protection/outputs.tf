output "protection_state" {
  description = "The Proxmox hierarchy objects returned by Rubrik."
  value = {
    for key, protection in graphql_mutation.object_protection :
    key => jsondecode(protection.query_response).data.hierarchyObjects[0]
  }
}

output "object_ids" {
  description = "Map of configured Proxmox object keys to Rubrik inventory IDs."
  value       = { for key, object in local.objects_by_key : key => object.id }
}
