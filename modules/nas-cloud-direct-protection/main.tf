data "graphql_query" "share_by_name" {
  for_each = var.shares

  query = file("${path.module}/../../gql_files/lookup-cloud-direct-share-by-name.graphql")
  query_variables = {
    name       = jsonencode(each.value.name)
    systemName = jsonencode(each.value.system_name)
    first      = "100"
    after      = ""
  }
  paginated = true
}

locals {
  shares_by_key = {
    for key, query in data.graphql_query.share_by_name :
    key => one(flatten([
      for page in jsondecode(query.query_response).paginatedResponseData :
      page.cloudDirectNasShares.nodes
    ]))
  }
}

resource "graphql_mutation" "share_protection" {
  for_each = local.shares_by_key

  mutation_variables = {
    input = jsonencode({
      objectIds           = [each.value.id]
      slaDomainAssignType = "protectWithSlaId"
      slaOptionalId       = lookup(var.sla_ids, each.key, "")
    })
  }

  read_query_variables = {
    fids = jsonencode([each.value.id])
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
  read_query      = file("${path.module}/../../gql_files/query-hierarchy-objects.graphql")

  lifecycle {
    precondition {
      condition = can(regex(
        "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$",
        lookup(var.sla_ids, each.key, "")
      ))
      error_message = "Each NAS Cloud Direct share must be assigned a valid SLA Domain UUID in sla_ids."
    }
  }

  enable_remote_state_verification = false
}
