terraform {
  required_providers {
    graphql = {
      source  = "sullivtr/graphql"
      version = ">= 2.4.0"
    }
  }
}

data "graphql_query" "object_by_name" {
  for_each = var.objects

  query = file("${path.module}/../../gql_files/lookup-proxmox-object-by-name.graphql")
  query_variables = {
    name  = jsonencode(each.value.name)
    first = "100"
    after = ""
  }
  paginated = true
}

locals {
  objects_by_key = {
    for key, query in data.graphql_query.object_by_name :
    key => one([
      for object in flatten([
        for page in jsondecode(query.query_response).paginatedResponseData :
        page.hierarchySnappables.nodes
      ]) : object
      if object.objectType == var.objects[key].object_type
    ])
  }
}

resource "graphql_mutation" "object_protection" {
  for_each = local.objects_by_key

  mutation_variables = {
    input = jsonencode({
      objectIds           = [each.value.id]
      slaDomainAssignType = "protectWithSlaId"
      slaOptionalId       = var.sla_id
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

  enable_remote_state_verification = false
}
