output "sla_domain_ids" {
  description = "Map of configured SLA Domain keys to Rubrik IDs."
  value       = { for key, domain in module.rubrik_sla_domains : key => domain.id }
}

output "object_inventory_role_ids" {
  description = "Map of configured object inventory role keys to Rubrik role IDs."
  value       = { for key, role in module.object_inventory_role : key => role.role_id }
}

output "vsphere_vm_ids" {
  description = "Map of configured vSphere VM names to Rubrik inventory IDs."
  value       = try(values(module.object_inventory_role)[0].vsphere_vm_ids, {})
}

output "vsphere_folder_ids" {
  description = "Map of configured vSphere folder names to Rubrik inventory IDs."
  value       = try(values(module.object_inventory_role)[0].vsphere_folder_ids, {})
}

output "postgresql_db_cluster_ids" {
  description = "Map of configured PostgreSQL database cluster names to Rubrik inventory IDs."
  value       = try(values(module.object_inventory_role)[0].postgresql_db_cluster_ids, {})
}

output "nas_share_ids" {
  description = "Map of configured existing NAS share names to Rubrik inventory IDs."
  value       = try(values(module.object_inventory_role)[0].nas_share_ids, {})
}

output "linux_fileset_ids" {
  description = "Map of configured Linux fileset assignment keys to Rubrik fileset IDs."
  value       = module.linux_fileset_protection.fileset_ids
}

output "kubernetes_cluster_ids" {
  description = "Map of configured Kubernetes cluster names to Rubrik inventory IDs."
  value       = module.kubernetes_protection.cluster_ids
}

output "kubernetes_protection_set_ids" {
  description = "Map of configured Kubernetes protection-set names to Rubrik inventory IDs."
  value       = module.kubernetes_protection.protection_set_ids
}

output "kubernetes_namespace_ids" {
  description = "Map of configured Kubernetes namespace keys to Rubrik inventory IDs."
  value       = module.kubernetes_protection.namespace_ids
}

output "proxmox_object_ids" {
  description = "Map of configured Proxmox object keys to Rubrik inventory IDs."
  value       = module.proxmox_protection.object_ids
}

output "classification_analyzer_ids" {
  description = "Map of configured custom analyzer names to Rubrik IDs."
  value       = module.classification_policy_analyzers.analyzer_ids
}

output "classification_policy_ids" {
  description = "Map of configured classification policy names to Rubrik IDs."
  value       = module.classification_policy_analyzers.policy_ids
}

output "sensitive_data_summary" {
  description = "Rubrik sensitive-data summary, or null when reporting is disabled."
  value       = module.sensitive_data_discovery.sensitive_data_summary
}

output "data_discovery_object_counts" {
  description = "Rubrik counts for assigned, unassigned, and unsupported discovery objects, or null when reporting is disabled."
  value       = module.sensitive_data_discovery.discovery_object_counts
}

output "nas_server_ids" {
  description = "Map of configured NAS server keys to Rubrik server IDs."
  value       = module.nas_share_protection.nas_server_ids
}

output "nas_cloud_direct_registration_job_ids" {
  description = "Map of configured NAS Cloud Direct system keys to asynchronous registration job IDs."
  value       = module.nas_cloud_direct_systems.registration_job_ids
}

output "nas_cloud_direct_share_ids" {
  description = "Map of configured NAS Cloud Direct share keys to Rubrik inventory IDs."
  value       = module.nas_cloud_direct_protection.share_ids
}

output "service_account_client_id" {
  description = "Map of service account keys to OAuth client IDs."
  value       = { for key, account in module.automation_service_account : key => account.client_id }
}

output "service_account_client_secret" {
  description = "Sensitive map of service account keys to OAuth client secrets."
  value       = { for key, account in module.automation_service_account : key => account.client_secret }
  sensitive   = true
}

output "service_account_access_token_uri" {
  description = "Map of service account keys to OAuth token endpoints."
  value       = { for key, account in module.automation_service_account : key => account.access_token_uri }
}

output "vsphere_server_ids" {
  description = "Map of configured vSphere server keys to Rubrik inventory IDs."
  value       = module.vsphere_server_registration.server_ids
}

output "proxmox_environment_ids" {
  description = "Map of configured Proxmox host keys to Rubrik environment IDs."
  value       = module.proxmox_hosts.environment_ids
}

output "tape_archival_target_ids" {
  description = "Map of configured tape archival target keys to Rubrik IDs."
  value       = module.tape_archival_targets.target_ids
}

output "tape_reader_target_ids" {
  description = "Map of configured tape reader target keys to Rubrik IDs."
  value       = module.tape_archival_targets.reader_target_ids
}
