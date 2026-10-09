data "graphql_query" "vsphere_vm_by_name" {
  for_each = var.vsphere_vm_names

  query = file("${path.module}/../../gql_files/lookup-vsphere-vm-by-name.graphql")
  query_variables = {
    name  = jsonencode(each.value)
    first = "100"
    after = ""
  }
  paginated = true
}

data "graphql_query" "vsphere_folder_by_name" {
  for_each = var.vsphere_folder_names

  query = file("${path.module}/../../gql_files/lookup-vsphere-folder-by-name.graphql")
  query_variables = {
    name  = jsonencode(each.value)
    first = "100"
    after = ""
  }
  paginated = true
}

data "graphql_query" "postgresql_cluster_by_name" {
  for_each = var.postgresql_db_cluster_names

  query = file("${path.module}/../../gql_files/lookup-postgresql-cluster-by-name.graphql")
  query_variables = {
    name  = jsonencode(each.value)
    first = "100"
    after = ""
  }
  paginated = true
}

data "graphql_query" "nas_share_by_name" {
  for_each = var.nas_share_names

  query = file("${path.module}/../../gql_files/lookup-nas-share-by-name.graphql")
  query_variables = {
    name  = jsonencode(each.value)
    first = "100"
    after = ""
  }
  paginated = true
}

locals {
  vsphere_vm_ids = {
    for name, query in data.graphql_query.vsphere_vm_by_name :
    name => one(flatten([
      for page in jsondecode(query.query_response).paginatedResponseData :
      page.vSphereVmNewConnection.nodes
    ])).id
  }

  vsphere_folder_ids = {
    for name, query in data.graphql_query.vsphere_folder_by_name :
    name => one(flatten([
      for page in jsondecode(query.query_response).paginatedResponseData :
      page.vSphereFolders.nodes
    ])).id
  }

  postgresql_db_cluster_ids = {
    for name, query in data.graphql_query.postgresql_cluster_by_name :
    name => one(flatten([
      for page in jsondecode(query.query_response).paginatedResponseData :
      page.postgreSQLDbClusters.nodes
    ])).id
  }

  nas_share_ids = {
    for name, query in data.graphql_query.nas_share_by_name :
    name => one(flatten([
      for page in jsondecode(query.query_response).paginatedResponseData :
      page.nasShares.nodes
    ])).id
  }
}

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
