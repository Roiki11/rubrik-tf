output "database_cluster_protection_state" {
  description = "The PostgreSQL database cluster details returned by Rubrik."
  value = {
    for cluster_id, protection in graphql_mutation.postgresql_protection :
    cluster_id => jsondecode(protection.query_response).data.postgreSQLDbCluster
  }
}
