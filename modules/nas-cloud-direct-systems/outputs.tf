output "registration_job_ids" {
  description = "Map of configured NAS Cloud Direct system keys to asynchronous registration job IDs."
  value = {
    for key, system in graphql_mutation.system :
    key => system.computed_update_operation_variables.job_id
  }
}
