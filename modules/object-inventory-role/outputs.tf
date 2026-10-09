output "role_id" {
  description = "Rubrik ID of the managed inventory visibility role."
  value       = graphql_mutation.object_inventory_role.computed_update_operation_variables.id
}

output "role_state" {
  description = "The role details returned by Rubrik."
  value       = jsondecode(graphql_mutation.object_inventory_role.query_response).data.getAllRolesInOrgConnection.nodes
}
