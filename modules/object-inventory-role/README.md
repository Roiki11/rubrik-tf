# Rubrik Object Inventory Role

Creates a custom Rubrik role granting `VIEW_INVENTORY` across the account and
exposes its role ID. The `VIEW_INVENTORY` permission is submitted with an empty
`objectsForHierarchyTypes` scope, which requests account-wide inventory
visibility. This role is read-only and does not grant protection, recovery, or
administrative operations.

```hcl
module "object_inventory_role" {
  source = "./modules/object-inventory-role"

  name = "Terraform object inventory reader"
}
```

The ID-to-name GraphQL operation is
`gql_files/query-object-ids-with-names.graphql`. Pass the object IDs through its
`fids` variable to retrieve each object's ID and name.

The role uses Rubrik's supported `mutateRole` API (rather than the deprecated
`createRole`/`updateRole` operations). Creating or changing the role requires
the caller's API identity to have role-management permission. Removing the
Terraform role resource deletes the role; ensure it is no longer assigned
before destroying it.
