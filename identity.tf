module "object_inventory_role" {
  source   = "./modules/object-inventory-role"
  for_each = var.object_inventory_roles

  name                        = each.value.name
  description                 = each.value.description
  vsphere_vm_names            = toset(keys(var.vsphere_vms))
  vsphere_folder_names        = toset(keys(var.vsphere_folders))
  postgresql_db_cluster_names = toset(keys(var.postgresql_clusters))
  nas_share_names             = toset(keys(var.nas_existing_shares))
}

module "automation_service_account" {
  source   = "./modules/service-account"
  for_each = var.service_accounts

  name        = each.value.name
  description = each.value.description
  role_ids = setunion(
    each.value.role_ids,
    toset([for key in each.value.inventory_role_keys : module.object_inventory_role[key].role_id])
  )
}
