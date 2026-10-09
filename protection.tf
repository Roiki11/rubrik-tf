module "rubrik_sla_domains" {
  source   = "./modules/sla-domain"
  for_each = var.sla_domains

  name              = each.value.name
  description       = try(each.value.description, null)
  object_types      = each.value.object_types
  snapshot_schedule = each.value.snapshot_schedule
  archival_specs    = try(each.value.archival_specs, [])
}

locals {
  vsphere_vm_sla_ids = {
    for name, sla_key in var.vsphere_vm_sla_domain_keys :
    name => try(module.rubrik_sla_domains[sla_key].id, "")
  }
  postgresql_sla_ids = {
    for name, sla_key in var.postgresql_sla_domain_keys :
    name => try(module.rubrik_sla_domains[sla_key].id, "")
  }
  linux_fileset_sla_ids = {
    for key, sla_key in var.linux_fileset_sla_domain_keys :
    "assignment:${key}" => try(module.rubrik_sla_domains[sla_key].id, "")
  }
  kubernetes_sla_ids = merge(
    {
      for name, sla_key in var.kubernetes_cluster_sla_domain_keys :
      "cluster:${name}" => try(module.rubrik_sla_domains[sla_key].id, "")
    },
    {
      for name, sla_key in var.kubernetes_protection_set_sla_domain_keys :
      "protection_set:${name}" => try(module.rubrik_sla_domains[sla_key].id, "")
    },
    {
      for key, sla_key in var.kubernetes_namespace_sla_domain_keys :
      "namespace:${key}" => try(module.rubrik_sla_domains[sla_key].id, "")
    }
  )
  proxmox_sla_ids = {
    for key, sla_key in var.proxmox_object_sla_domain_keys :
    "object:${key}" => try(module.rubrik_sla_domains[sla_key].id, "")
  }
  nas_sla_ids = merge(
    {
      for name, sla_key in var.nas_share_sla_domain_keys :
      "existing:${name}" => try(module.rubrik_sla_domains[sla_key].id, "")
    },
    {
      for key, sla_key in var.nas_configured_share_sla_domain_keys :
      "configured:${key}" => try(module.rubrik_sla_domains[sla_key].id, "")
    }
  )
  nas_cloud_direct_sla_ids = {
    for key, sla_key in var.nas_cloud_direct_share_sla_domain_keys :
    key => try(module.rubrik_sla_domains[sla_key].id, "")
  }
  vsphere_container_sla_ids = merge(
    {
      for name, sla_key in var.vsphere_folder_sla_domain_keys :
      "folder:${name}" => try(module.rubrik_sla_domains[sla_key].id, "")
    },
    {
      for id, sla_key in var.vsphere_tag_sla_domain_keys :
      "tag:${id}" => try(module.rubrik_sla_domains[sla_key].id, "")
    }
  )
}

module "vsphere_vm_protection" {
  source = "./modules/vsphere-vm-protection"

  vm_names = var.vsphere_vm_names
  sla_ids  = local.vsphere_vm_sla_ids
}

module "postgresql_protection" {
  source = "./modules/postgresql-protection"

  database_cluster_names = var.postgresql_db_cluster_names
  sla_ids                = local.postgresql_sla_ids
}

module "linux_fileset_protection" {
  source = "./modules/linux-fileset-protection"

  cluster_uuid        = var.linux_fileset_cluster_uuid
  fileset_templates   = var.linux_fileset_templates
  fileset_assignments = var.linux_fileset_assignments
  sla_ids             = local.linux_fileset_sla_ids
}

module "kubernetes_protection" {
  source = "./modules/kubernetes-protection"

  cluster_names        = var.kubernetes_cluster_names
  protection_set_names = var.kubernetes_protection_set_names
  namespaces           = var.kubernetes_namespaces
  sla_ids              = local.kubernetes_sla_ids
}

module "proxmox_protection" {
  source = "./modules/proxmox-protection"

  objects = var.proxmox_objects
  sla_ids = local.proxmox_sla_ids
}

module "nas_cloud_direct_protection" {
  source = "./modules/nas-cloud-direct-protection"

  shares  = var.nas_cloud_direct_shares
  sla_ids = local.nas_cloud_direct_sla_ids
}

module "vsphere_container_sla_assignments" {
  source = "./modules/vsphere-container-sla-assignment"

  folder_names = var.vsphere_folder_names
  tag_ids      = var.vsphere_tag_ids
  sla_ids      = local.vsphere_container_sla_ids
}
