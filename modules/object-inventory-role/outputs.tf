output "role_id" {
  description = "Rubrik ID of the managed inventory visibility role."
  value       = graphql_mutation.object_inventory_role.computed_update_operation_variables.id
}

output "role_state" {
  description = "The role details returned by Rubrik."
  value       = jsondecode(graphql_mutation.object_inventory_role.query_response).data.getAllRolesInOrgConnection.nodes
}

output "vsphere_vm_ids" {
  description = "Map of exact vSphere VM names to Rubrik inventory IDs."
  value       = local.vsphere_vm_ids
}

output "vsphere_folder_ids" {
  description = "Map of exact vSphere folder names to Rubrik inventory IDs."
  value       = local.vsphere_folder_ids
}

output "postgresql_db_cluster_ids" {
  description = "Map of exact PostgreSQL database cluster names to Rubrik inventory IDs."
  value       = local.postgresql_db_cluster_ids
}

output "nas_share_ids" {
  description = "Map of exact existing NAS share names to Rubrik inventory IDs."
  value       = local.nas_share_ids
}
