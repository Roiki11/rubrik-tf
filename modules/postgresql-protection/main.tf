resource "graphql_mutation" "postgresql_protection" {
  for_each = var.database_cluster_ids

  mutation_variables = {
    input = jsonencode({
      objectIds           = [each.value]
      slaDomainAssignType = "protectWithSlaId"
      slaOptionalId       = var.sla_id
    })
  }

  read_query_variables = {
    fid = jsonencode(each.value)
  }

  delete_mutation_variables = {
    input = jsonencode({
      objectIds           = [each.value]
      slaDomainAssignType = "doNotProtect"
    })
  }

  compute_mutation_keys = {}

  create_mutation = file("${path.module}/../../gql_files/assign-sla.graphql")
  update_mutation = file("${path.module}/../../gql_files/assign-sla.graphql")
  delete_mutation = file("${path.module}/../../gql_files/assign-sla.graphql")
  read_query      = file("${path.module}/../../gql_files/postgresql-db-cluster-by-id.graphql")

  enable_remote_state_verification = false
}
