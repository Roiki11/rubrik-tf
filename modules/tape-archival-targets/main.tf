resource "graphql_mutation" "target" {
  for_each = nonsensitive(toset(keys(var.targets)))

  mutation_variables = {
    clusterUuid           = jsonencode(var.targets[each.value].cluster_uuid)
    destinationFolderName = jsonencode(var.targets[each.value].destination_folder_name)
    encryptionPassword    = jsonencode(var.targets[each.value].encryption_password)
    hostName              = jsonencode(var.targets[each.value].host_name)
    hostPort              = jsonencode(var.targets[each.value].host_port)
    integralVolumeName    = jsonencode(var.targets[each.value].integral_volume_name)
    name                  = jsonencode(var.targets[each.value].name)
    password              = jsonencode(var.targets[each.value].password)
    username              = jsonencode(var.targets[each.value].username)
  }

  read_query_variables  = {}
  compute_mutation_keys = { id = "data.createTapeTarget.id" }
  compute_from_create   = true

  create_mutation = file("${path.module}/../../gql_files/mutation-create-tape-target-managed.graphql")
  update_mutation = file("${path.module}/../../gql_files/mutation-update-tape-target-managed.graphql")
  delete_mutation = file("${path.module}/../../gql_files/mutation-preserve-tape-target-managed.graphql")
  read_query      = file("${path.module}/../../gql_files/query-empty.graphql")

  enable_remote_state_verification = false
}

resource "graphql_mutation" "reader_target" {
  for_each = nonsensitive(toset(keys(var.reader_targets)))

  mutation_variables = {
    archivalDataSourceIds = jsonencode(sort(tolist(var.reader_targets[each.value].archival_data_source_ids)))
    clusterUuid           = jsonencode(var.reader_targets[each.value].cluster_uuid)
    destinationFolderName = jsonencode(var.reader_targets[each.value].destination_folder_name)
    encryptionPassword    = jsonencode(var.reader_targets[each.value].encryption_password)
    hostName              = jsonencode(var.reader_targets[each.value].host_name)
    hostPort              = jsonencode(var.reader_targets[each.value].host_port)
    integralVolumeName    = jsonencode(var.reader_targets[each.value].integral_volume_name)
    name                  = jsonencode(var.reader_targets[each.value].name)
    password              = jsonencode(var.reader_targets[each.value].password)
    readerRetrievalMethod = jsonencode(var.reader_targets[each.value].reader_retrieval_method)
    username              = jsonencode(var.reader_targets[each.value].username)
  }

  read_query_variables  = {}
  compute_mutation_keys = { id = "data.createTapeReaderTarget.id" }
  compute_from_create   = true

  create_mutation = file("${path.module}/../../gql_files/mutation-create-tape-reader-target-managed.graphql")
  update_mutation = file("${path.module}/../../gql_files/mutation-update-tape-target-managed.graphql")
  delete_mutation = file("${path.module}/../../gql_files/mutation-preserve-tape-target-managed.graphql")
  read_query      = file("${path.module}/../../gql_files/query-empty.graphql")

  enable_remote_state_verification = false
}
