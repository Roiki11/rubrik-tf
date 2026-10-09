output "assignment_responses" {
  description = "Latest Rubrik query responses for the assigned folders and tags."
  value = {
    for target, assignment in graphql_mutation.sla_assignment :
    target => jsondecode(assignment.query_response).data
  }
}
