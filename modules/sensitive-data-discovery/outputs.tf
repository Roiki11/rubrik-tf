output "sensitive_data_summary" {
  description = "Sensitive data summary returned by Rubrik, or null when discovery queries are disabled."
  value = var.enabled ? jsondecode(
    data.graphql_query.sensitive_data_summary["current"].query_response
  ).data.sensitiveDataSummary : null
}

output "discovery_object_counts" {
  description = "Counts of assigned, unassigned, and unsupported data discovery objects, or null when disabled."
  value = var.enabled ? jsondecode(
    data.graphql_query.discovery_object_counts["current"].query_response
  ).data.dataDiscoveryObjectsCount : null
}
