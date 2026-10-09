output "cluster_protection_state" {
  description = "The Kubernetes cluster details returned by Rubrik."
  value = {
    for cluster_name, protection in graphql_mutation.cluster_protection :
    cluster_name => jsondecode(protection.query_response).data.k8sCluster
  }
}

output "protection_set_state" {
  description = "The Kubernetes protection-set details returned by Rubrik."
  value = {
    for protection_set_name, protection in graphql_mutation.protection_set_protection :
    protection_set_name => jsondecode(protection.query_response).data.kubernetesProtectionSet
  }
}

output "cluster_ids" {
  description = "Map of configured Kubernetes cluster names to Rubrik inventory IDs."
  value       = { for name, cluster in local.clusters_for_protection : name => cluster.id }
}

output "protection_set_ids" {
  description = "Map of configured Kubernetes protection-set names to Rubrik inventory IDs."
  value       = { for name, protection_set in local.protection_sets_by_name : name => protection_set.id }
}

output "namespace_ids" {
  description = "Map of configured Terraform namespace keys to Rubrik inventory IDs."
  value       = { for key, namespace in local.namespaces_by_key : key => namespace.id }
}

output "namespace_protection_state" {
  description = "The Kubernetes namespace details returned by Rubrik."
  value = {
    for key, protection in graphql_mutation.namespace_protection :
    key => jsondecode(protection.query_response).data.k8sNamespace
  }
}
