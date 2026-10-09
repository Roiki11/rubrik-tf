output "target_ids" {
  description = "Map of tape archival target keys to Rubrik IDs."
  value = {
    for key, target in graphql_mutation.target :
    key => target.computed_update_operation_variables.id
  }
}

output "reader_target_ids" {
  description = "Map of tape reader target keys to Rubrik IDs."
  value = {
    for key, target in graphql_mutation.reader_target :
    key => target.computed_update_operation_variables.id
  }
}

output "target_states" {
  description = "Tape archival target create/update results returned by Rubrik."
  value = {
    for key, target in graphql_mutation.target :
    key => jsondecode(target.query_response).data
  }
}

output "reader_target_states" {
  description = "Tape reader target create/update results returned by Rubrik."
  value = {
    for key, target in graphql_mutation.reader_target :
    key => jsondecode(target.query_response).data
  }
}
