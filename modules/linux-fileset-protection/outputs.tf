output "fileset_ids" {
  description = "Map of fileset assignment keys to their Rubrik Linux fileset IDs."
  value       = local.fileset_ids
}

output "template_ids" {
  description = "Map of Linux fileset template names to their Rubrik IDs."
  value = {
    for name, template in graphql_mutation.fileset_template :
    name => template.computed_update_operation_variables.id
  }
}
