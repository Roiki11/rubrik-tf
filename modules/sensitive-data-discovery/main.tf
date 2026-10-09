locals {
  enabled_queries = var.enabled ? { current = true } : {}
}

data "graphql_query" "sensitive_data_summary" {
  for_each = local.enabled_queries

  query = file("${path.module}/../../gql_files/query-sensitive-data-summary.graphql")
  query_variables = {
    input = jsonencode(var.summary_input)
  }
}

data "graphql_query" "discovery_object_counts" {
  for_each = local.enabled_queries

  query           = file("${path.module}/../../gql_files/query-data-discovery-objects-count.graphql")
  query_variables = {}
}
