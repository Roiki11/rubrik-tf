resource "graphql_mutation" "sla_domain" {
  mutation_variables = {
    name             = jsonencode(var.name)
    description      = jsonencode(var.description)
    objectTypes      = jsonencode(sort(tolist(var.object_types)))
    snapshotSchedule = var.snapshot_schedule == null ? "null" : jsonencode(var.snapshot_schedule)
  }

  read_query_variables = {}

  compute_mutation_keys = {
    id = "data.createGlobalSla.id"
  }

  compute_from_create = true

  create_mutation = file("${path.module}/../../gql_files/create-global-sla-managed.graphql")
  update_mutation = file("${path.module}/../../gql_files/update-global-sla-managed.graphql")
  delete_mutation = file("${path.module}/../../gql_files/mutation-delete-global-sla.graphql")
  read_query      = file("${path.module}/../../gql_files/query-sla-domain.graphql")

  enable_remote_state_verification = false
}
