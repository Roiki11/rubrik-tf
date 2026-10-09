output "analyzer_ids" {
  description = "Map of configured custom analyzer names to Rubrik IDs."
  value = {
    for name, analyzer in graphql_mutation.custom_analyzer :
    name => analyzer.computed_update_operation_variables.id
  }
}

output "analyzer_states" {
  description = "Custom analyzer details returned by Rubrik."
  value = {
    for name, analyzer in graphql_mutation.custom_analyzer :
    name => jsondecode(analyzer.query_response).data.customAnalyzer
  }
}

output "policy_ids" {
  description = "Map of configured classification policy names to Rubrik IDs."
  value = {
    for name, policy in graphql_mutation.classification_policy :
    name => policy.computed_update_operation_variables.id
  }
}

output "policy_states" {
  description = "Classification policy details returned by Rubrik."
  value = {
    for name, policy in graphql_mutation.classification_policy :
    name => jsondecode(policy.query_response).data.policy
  }
}
