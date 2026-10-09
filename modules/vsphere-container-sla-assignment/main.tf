locals {
  folders_by_name = {
    for name, query in data.graphql_query.folder_by_name :
    "folder:${name}" => {
      id = one(flatten([
        for page in jsondecode(query.query_response).paginatedResponseData :
        page.vSphereFolders.nodes
      ])).id
      kind = "folder"
    }
  }
  tags_by_id = {
    for id in var.tag_ids : "tag:${id}" => {
      id   = id
      kind = "tag"
    }
  }
  targets = merge(local.folders_by_name, local.tags_by_id)
}

data "graphql_query" "folder_by_name" {
  for_each = var.folder_names

  query = file("${path.module}/../../gql_files/lookup-vsphere-folder-by-name.graphql")
  query_variables = {
    name  = jsonencode(each.value)
    first = "100"
    after = ""
  }
  paginated = true
}

resource "graphql_mutation" "sla_assignment" {
  for_each = local.targets

  mutation_variables = {
    input = jsonencode({
      objectIds           = [each.value.id]
      slaDomainAssignType = "protectWithSlaId"
      slaOptionalId       = var.sla_id
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
  read_query = each.value.kind == "folder" ? (
    file("${path.module}/../../gql_files/query-v-sphere-folder.graphql")
    ) : (
    file("${path.module}/../../gql_files/query-v-sphere-tag.graphql")
  )

  enable_remote_state_verification = false
}
