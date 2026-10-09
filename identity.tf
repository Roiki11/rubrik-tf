module "object_inventory_role" {
  source   = "./modules/object-inventory-role"
  for_each = var.object_inventory_roles

  name                        = each.value.name
  description                 = each.value.description
  vsphere_vm_names            = var.vsphere_vm_names
  vsphere_folder_names        = var.vsphere_folder_names
  postgresql_db_cluster_names = var.postgresql_db_cluster_names
  nas_share_names             = var.nas_share_names
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
