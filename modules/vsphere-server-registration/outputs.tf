output "server_ids" {
  description = "Map of configured vSphere server keys to Rubrik inventory IDs."
  value = {
    for key, server in graphql_mutation.server :
    key => server.computed_update_operation_variables.id
  }
}

output "server_states" {
  description = "Registered vSphere server details returned by Rubrik."
  value = {
    for key, server in graphql_mutation.server :
    key => jsondecode(server.query_response).data.vSphereVCenterConnection.nodes
  }
}
