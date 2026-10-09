output "share_protection_state" {
  description = "The NAS share details returned by Rubrik after assignment."
  value = {
    for share_name, protection in graphql_mutation.nas_share_protection :
    share_name => jsondecode(protection.query_response).data.nasShare
  }
}
