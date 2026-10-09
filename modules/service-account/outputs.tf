output "id" {
  description = "Rubrik service account ID."
  value       = graphql_mutation.service_account.computed_update_operation_variables.id
}

output "client_id" {
  description = "OAuth client ID for the service account."
  value       = graphql_mutation.service_account.computed_update_operation_variables.clientId
}

output "client_secret" {
  description = "OAuth client secret. This secret is sensitive and is stored in Terraform state."
  value       = graphql_mutation.service_account.computed_update_operation_variables.clientSecret
  sensitive   = true
}

output "access_token_uri" {
  description = "OAuth access-token endpoint for exchanging the service-account credentials."
  value       = graphql_mutation.service_account.computed_update_operation_variables.accessTokenUri
}

output "state" {
  description = "Service account details returned by Rubrik."
  value       = jsondecode(graphql_mutation.service_account.query_response).data.serviceAccounts.nodes
}
