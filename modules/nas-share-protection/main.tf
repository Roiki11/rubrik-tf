data "graphql_query" "share_by_name" {
  for_each = var.share_names

  query = file("${path.module}/../../gql_files/lookup-nas-share-by-name.graphql")
  query_variables = {
    name  = jsonencode(each.value)
    first = "100"
    after = ""
  }
  paginated = true
}

locals {
  shares_by_name = {
    for name, query in data.graphql_query.share_by_name :
    name => one(flatten([
      for page in jsondecode(query.query_response).paginatedResponseData :
      page.nasShares.nodes
    ]))
  }
}

resource "graphql_mutation" "nas_share_protection" {
  for_each = local.shares_by_name

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
  read_query      = file("${path.module}/../../gql_files/query-nas-share.graphql")

  enable_remote_state_verification = false
}
