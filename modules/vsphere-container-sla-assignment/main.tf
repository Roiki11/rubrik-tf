locals {
  targets = merge(
    {
      for id in var.folder_ids : "folder:${id}" => {
        id   = id
        kind = "folder"
      }
    },
    {
      for id in var.tag_ids : "tag:${id}" => {
        id   = id
        kind = "tag"
      }
    },
  )
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
