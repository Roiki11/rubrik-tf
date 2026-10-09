resource "graphql_mutation" "object_inventory_role" {
  mutation_variables = {
    name                = jsonencode(var.name)
    description         = jsonencode(var.description)
    permissions         = jsonencode([{ operation = "VIEW_INVENTORY", objectsForHierarchyTypes = [] }])
    protectableClusters = jsonencode([])
  }

  read_query_variables = {
    nameFilter = jsonencode(var.name)
  }

  compute_mutation_keys = {
    id = "data.mutateRole"
  }

  compute_from_create = true

  create_mutation = file("${path.module}/../../gql_files/mutation-mutate-role-managed.graphql")
  update_mutation = file("${path.module}/../../gql_files/mutation-mutate-role-managed.graphql")
  delete_mutation = file("${path.module}/../../gql_files/mutation-delete-role-managed.graphql")
  read_query      = file("${path.module}/../../gql_files/query-role-by-name.graphql")

  enable_remote_state_verification = false
}
