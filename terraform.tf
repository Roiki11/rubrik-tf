terraform {
  required_providers {
    graphql = {
      source  = "sullivtr/graphql"
      version = ">= 2.4.0"
    }
  }
}

provider "graphql" {
  url = var.rubrik_graphql_url

  headers = {
    Authorization = "Bearer ${var.rubrik_api_token}"
  }
}

module "vsphere_vm_protection" {
  source = "./modules/vsphere-vm-protection"

  vm_names = var.vsphere_vm_names
  sla_id   = module.rubrik_sla_domain.id
}

module "rubrik_sla_domain" {
  source = "./modules/sla-domain"

  name              = var.sla_domain_name
  description       = var.sla_domain_description
  object_types      = var.sla_domain_object_types
  snapshot_schedule = var.sla_domain_snapshot_schedule
  archival_specs    = var.sla_domain_archival_specs
}

module "postgresql_protection" {
  source = "./modules/postgresql-protection"

  database_cluster_names = var.postgresql_db_cluster_names
  sla_id                 = module.rubrik_sla_domain.id
}

module "linux_fileset_protection" {
  source = "./modules/linux-fileset-protection"

  cluster_uuid        = var.linux_fileset_cluster_uuid
  fileset_templates   = var.linux_fileset_templates
  fileset_assignments = var.linux_fileset_assignments
  sla_id              = module.rubrik_sla_domain.id
}

module "kubernetes_protection" {
  source = "./modules/kubernetes-protection"

  cluster_names        = var.kubernetes_cluster_names
  protection_set_names = var.kubernetes_protection_set_names
  namespaces           = var.kubernetes_namespaces
  sla_id               = module.rubrik_sla_domain.id
}

module "proxmox_protection" {
  source = "./modules/proxmox-protection"

  objects = var.proxmox_objects
  sla_id  = module.rubrik_sla_domain.id
}

module "nas_share_protection" {
  source = "./modules/nas-share-protection"

  nas_server  = var.nas_server
  nas_shares  = var.nas_shares
  share_names = var.nas_share_names
  sla_id      = module.rubrik_sla_domain.id
}

module "vsphere_container_sla_assignments" {
  source = "./modules/vsphere-container-sla-assignment"

  folder_names = var.vsphere_folder_names
  tag_ids      = var.vsphere_tag_ids
  sla_id       = module.rubrik_sla_domain.id
}

module "object_inventory_role" {
  source = "./modules/object-inventory-role"

  name                        = var.object_inventory_role_name
  vsphere_vm_names            = var.vsphere_vm_names
  vsphere_folder_names        = var.vsphere_folder_names
  postgresql_db_cluster_names = var.postgresql_db_cluster_names
  nas_share_names             = var.nas_share_names
}

module "automation_service_account" {
  source = "./modules/service-account"

  name        = var.service_account_name
  description = var.service_account_description
  role_ids    = setunion(var.service_account_role_ids, [module.object_inventory_role.role_id])
}

output "object_inventory_role_id" {
  description = "Rubrik role ID for account-wide object inventory visibility."
  value       = module.object_inventory_role.role_id
}

output "vsphere_vm_ids" {
  description = "Map of configured vSphere VM names to Rubrik inventory IDs."
  value       = module.object_inventory_role.vsphere_vm_ids
}

output "vsphere_folder_ids" {
  description = "Map of configured vSphere folder names to Rubrik inventory IDs."
  value       = module.object_inventory_role.vsphere_folder_ids
}

output "postgresql_db_cluster_ids" {
  description = "Map of configured PostgreSQL database cluster names to Rubrik inventory IDs."
  value       = module.object_inventory_role.postgresql_db_cluster_ids
}

output "nas_share_ids" {
  description = "Map of configured existing NAS share names to Rubrik inventory IDs."
  value       = module.object_inventory_role.nas_share_ids
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

output "nas_server_id" {
  description = "Rubrik ID of the registered NAS server, or null if none was configured."
  value       = module.nas_share_protection.nas_server_id
}

output "service_account_client_id" {
  description = "OAuth client ID for the managed Rubrik service account."
  value       = module.automation_service_account.client_id
}

output "service_account_client_secret" {
  description = "Sensitive OAuth client secret for the managed Rubrik service account."
  value       = module.automation_service_account.client_secret
  sensitive   = true
}

output "service_account_access_token_uri" {
  description = "OAuth endpoint for exchanging the service-account credentials."
  value       = module.automation_service_account.access_token_uri
}
