output "id" {
  description = "Rubrik ID of the managed SLA Domain."
  value       = graphql_mutation.sla_domain.computed_update_operation_variables.id
}

output "state" {
  description = "The SLA Domain details returned by Rubrik."
  value       = jsondecode(graphql_mutation.sla_domain.query_response).data.slaDomain
}
