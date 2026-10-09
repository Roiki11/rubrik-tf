output "share_protection_state" {
  description = "The NAS share details returned by Rubrik after assignment."
  value = {
    for share_name, protection in graphql_mutation.nas_share_protection :
    share_name => jsondecode(protection.query_response).data.nasShare
  }
}

output "nas_server_id" {
  description = "Rubrik ID of the registered NAS server, or null if no server was configured."
  value       = local.nas_server_id
}

output "nas_share_configuration_state" {
  description = "Details returned by Rubrik for the manually added NAS shares."
  value = {
    for name, share in graphql_mutation.nas_share_configuration :
    name => jsondecode(share.query_response).data.nasShare
  }
}
