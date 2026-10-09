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
}

module "postgresql_protection" {
  source = "./modules/postgresql-protection"

  database_cluster_names = var.postgresql_db_cluster_names
  sla_id                 = module.rubrik_sla_domain.id
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

  name = var.object_inventory_role_name
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
