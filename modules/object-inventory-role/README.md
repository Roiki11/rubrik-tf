# Rubrik Object Inventory Role

Creates a custom Rubrik role granting `VIEW_INVENTORY` across the account and
exposes its role ID. The `VIEW_INVENTORY` permission is submitted with an empty
`objectsForHierarchyTypes` scope, which requests account-wide inventory
visibility. This role is read-only and does not grant protection, recovery, or
administrative operations.

```hcl
module "object_inventory_role" {
  source = "./modules/object-inventory-role"

  name                        = "Terraform object inventory reader"
  vsphere_vm_names            = ["application-01"]
  vsphere_folder_names        = ["Production"]
  postgresql_db_cluster_names = ["postgres-production"]
  nas_share_names             = ["engineering-nfs"]
}
```

The optional name sets resolve exact names to IDs and are returned as maps
keyed by the supplied names:

- `vsphere_vm_ids`
- `vsphere_folder_ids`
- `postgresql_db_cluster_ids`
- `nas_share_ids`

Each lookup must resolve to exactly one object; missing or duplicate matches
fail the Terraform evaluation. The module uses the paginated lookup operations
in `gql_files/`. vSphere tags are not resolved by name; supply Rubrik tag UUIDs
directly to the SLA-assignment module.

Lookups execute through the caller's configured GraphQL provider credentials.
Creating this role does not switch the provider identity or automatically use
the service account to run the queries. To perform lookups as the service
account, configure the provider with an access token issued for that account
and assign this role to it.

The role uses Rubrik's supported `mutateRole` API (rather than the deprecated
`createRole`/`updateRole` operations). Creating or changing the role requires
the caller's API identity to have role-management permission. Removing the
Terraform role resource deletes the role; ensure it is no longer assigned
before destroying it.
