output "share_ids" {
  description = "Map of configured NAS Cloud Direct share keys to Rubrik inventory IDs."
  value       = { for key, share in local.shares_by_key : key => share.id }
}

output "protection_state" {
  description = "NAS Cloud Direct hierarchy details returned by Rubrik after SLA assignment."
  value = {
    for key, protection in graphql_mutation.share_protection :
    key => jsondecode(protection.query_response).data.hierarchyObjects[0]
  }
}
