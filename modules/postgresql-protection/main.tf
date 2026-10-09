data "graphql_query" "cluster_by_name" {
  for_each = var.database_cluster_names

  query = file("${path.module}/../../gql_files/lookup-postgresql-cluster-by-name.graphql")
  query_variables = {
    name  = jsonencode(each.value)
    first = "100"
    after = ""
  }
  paginated = true
}

locals {
  clusters_by_name = {
    for name, query in data.graphql_query.cluster_by_name :
    name => one(flatten([
      for page in jsondecode(query.query_response).paginatedResponseData :
      page.postgreSQLDbClusters.nodes
    ]))
  }
}

resource "graphql_mutation" "postgresql_protection" {
  for_each = local.clusters_by_name

  mutation_variables = {
    input = jsonencode({
      objectIds           = [each.value.id]
      slaDomainAssignType = "protectWithSlaId"
      slaOptionalId       = lookup(var.sla_ids, each.key, "")
    })
  }

  read_query_variables = {
    fid = jsonencode(each.value.id)
  }

  delete_mutation_variables = {
    input = jsonencode({
      objectIds           = [each.value.id]
      slaDomainAssignType = "doNotProtect"
    })
  }

  compute_mutation_keys = {}

  create_mutation = file("${path.module}/../../gql_files/assign-sla.graphql")
  update_mutation = file("${path.module}/../../gql_files/assign-sla.graphql")
  delete_mutation = file("${path.module}/../../gql_files/assign-sla.graphql")
  read_query      = file("${path.module}/../../gql_files/postgresql-db-cluster-by-id.graphql")

  lifecycle {
    precondition {
      condition = can(regex(
        "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$",
        lookup(var.sla_ids, each.key, "")
      ))
      error_message = "Each PostgreSQL cluster must be assigned a valid SLA Domain UUID in sla_ids."
    }
  }

  enable_remote_state_verification = false
}
