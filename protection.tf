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
    for name, sla_key in var.vsphere_vms :
    name => module.rubrik_sla_domains[sla_key].id
  }
  postgresql_sla_ids = {
    for name, sla_key in var.postgresql_clusters :
    name => module.rubrik_sla_domains[sla_key].id
  }
  linux_fileset_sla_ids = {
    for key, assignment in var.linux_fileset_assignments :
    "assignment:${key}" => module.rubrik_sla_domains[assignment.sla_domain_key].id
  }
  kubernetes_sla_ids = merge(
    {
      for name, sla_key in var.kubernetes.clusters :
      "cluster:${name}" => module.rubrik_sla_domains[sla_key].id
    },
    {
      for name, sla_key in var.kubernetes.protection_sets :
      "protection_set:${name}" => module.rubrik_sla_domains[sla_key].id
    },
    {
      for key, namespace in var.kubernetes.namespaces :
      "namespace:${key}" => module.rubrik_sla_domains[namespace.sla_domain_key].id
    }
  )
  proxmox_sla_ids = {
    for key, object in var.proxmox_objects :
    "object:${key}" => module.rubrik_sla_domains[object.sla_domain_key].id
  }
  nas_sla_ids = merge(
    {
      for name, sla_key in var.nas_existing_shares :
      "existing:${name}" => module.rubrik_sla_domains[sla_key].id
    },
    {
      for key, share in var.nas_shares :
      "configured:${key}" => module.rubrik_sla_domains[share.sla_domain_key].id
    }
  )
  nas_cloud_direct_sla_ids = {
    for key, share in var.nas_cloud_direct_shares :
    key => module.rubrik_sla_domains[share.sla_domain_key].id
  }
  vsphere_container_sla_ids = merge(
    {
      for name, sla_key in var.vsphere_folders :
      "folder:${name}" => module.rubrik_sla_domains[sla_key].id
    },
    {
      for id, sla_key in var.vsphere_tags :
      "tag:${id}" => module.rubrik_sla_domains[sla_key].id
    }
  )
}

module "vsphere_vm_protection" {
  source = "./modules/vsphere-vm-protection"

  vm_names = toset(keys(var.vsphere_vms))
  sla_ids  = local.vsphere_vm_sla_ids
}

module "postgresql_protection" {
  source = "./modules/postgresql-protection"

  database_cluster_names = toset(keys(var.postgresql_clusters))
  sla_ids                = local.postgresql_sla_ids
}

module "linux_fileset_protection" {
  source = "./modules/linux-fileset-protection"

  cluster_uuid        = try(local.rubrik_cluster_ids[var.linux_fileset_cluster_name], "")
  fileset_templates   = var.linux_fileset_templates
  fileset_assignments = var.linux_fileset_assignments
  sla_ids             = local.linux_fileset_sla_ids
}

module "kubernetes_protection" {
  source = "./modules/kubernetes-protection"

  cluster_names        = toset(keys(var.kubernetes.clusters))
  protection_set_names = toset(keys(var.kubernetes.protection_sets))
  namespaces           = var.kubernetes.namespaces
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

  folder_names = toset(keys(var.vsphere_folders))
  tag_ids      = toset(keys(var.vsphere_tags))
  sla_ids      = local.vsphere_container_sla_ids
}
