# Rubrik vSphere Folder and Tag SLA Assignments

Assigns an existing SLA Domain to vSphere folders selected by exact name and
tags selected by Rubrik UUID. The calling configuration must configure the
`sullivtr/graphql` provider.

```hcl
module "vsphere_container_sla_assignments" {
  source = "./modules/vsphere-container-sla-assignment"

  folder_names = [
    "Production",
  ]
  tag_ids = [
    "33333333-3333-3333-3333-333333333333",
  ]
  sla_ids = {
    "folder:Production" = "00000000-0000-0000-0000-000000000000"
    "tag:33333333-3333-3333-3333-333333333333" = "11111111-1111-1111-1111-111111111111"
  }
}
```

The module resolves each folder name using Rubrik's exact-name folder query and
uses `gql_files/assign-sla.graphql` to assign the SLA. Rubrik's GraphQL API
exposes vSphere tag lookup only by Rubrik UUID; a vCenter tag name/URN cannot be
used as the ID expected by `assignSla`. The module reads targets after
assignment with `gql_files/query-v-sphere-folder.graphql` or
`gql_files/query-v-sphere-tag.graphql`.
Destroying an assignment resource sets it to `doNotProtect`; it does not
delete the folder, tag, VMs, or snapshots.

Folder and tag assignments can affect multiple descendant VMs. Avoid managing
the same VM's effective SLA both directly and through a folder or tag unless
the inheritance/precedence behavior is intended. The Rubrik API determines
the resulting effective SLA.

Remote state verification is disabled because the GraphQL provider cannot
reconcile the nested assignment input against the folder or tag query
response. Changes made outside Terraform are not detected by this module.

Each folder name must match exactly one Rubrik object. Missing or ambiguous
names fail during planning. `sla_ids` is keyed by `folder:<exact name>` and
`tag:<Rubrik UUID>` so each container can use a different SLA.
