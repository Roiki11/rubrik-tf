resource "graphql_mutation" "service_account" {
  mutation_variables = {
    name        = jsonencode(var.name)
    description = jsonencode(var.description)
    roleIds     = jsonencode(sort(tolist(var.role_ids)))
  }

  read_query_variables = {
    searchText = jsonencode(var.name)
    first      = "100"
  }

  compute_mutation_keys = {
    id             = "data.createServiceAccount.clientId"
    clientId       = "data.createServiceAccount.clientId"
    clientSecret   = "data.createServiceAccount.clientSecret"
    accessTokenUri = "data.createServiceAccount.accessTokenUri"
  }

  compute_from_create = true
  force_replace       = true

  create_mutation = file("${path.module}/../../gql_files/create-service-account-managed.graphql")
  update_mutation = file("${path.module}/../../gql_files/update-service-account-managed.graphql")
  delete_mutation = file("${path.module}/../../gql_files/delete-service-account-managed.graphql")
  read_query      = file("${path.module}/../../gql_files/service-account-by-name.graphql")

  enable_remote_state_verification = false
}
