output "database_cluster_protection_state" {
  description = "The PostgreSQL database cluster details returned by Rubrik."
  value = {
    for cluster_name, protection in graphql_mutation.postgresql_protection :
    cluster_name => jsondecode(protection.query_response).data.postgreSQLDbCluster
  }
}
