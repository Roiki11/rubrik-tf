# Rubrik vSphere Folder and Tag SLA Assignments

Assigns an existing SLA Domain to each vSphere folder and tag ID. The calling
configuration must configure the `sullivtr/graphql` provider.

```hcl
module "vsphere_container_sla_assignments" {
  source = "./modules/vsphere-container-sla-assignment"

  folder_ids = [
    "11111111-1111-1111-1111-111111111111",
  ]
  tag_ids = [
    "22222222-2222-2222-2222-222222222222",
  ]
  sla_id = module.rubrik_sla_domain.id
}
```

The module uses `gql_files/assign-sla.graphql` to assign the SLA and
`gql_files/query-v-sphere-folder.graphql` or
`gql_files/query-v-sphere-tag.graphql` to read the target after assignment.
Destroying an assignment resource sets it to `doNotProtect`; it does not
delete the folder, tag, VMs, or snapshots.

Folder and tag assignments can affect multiple descendant VMs. Avoid managing
the same VM's effective SLA both directly and through a folder or tag unless
the inheritance/precedence behavior is intended. The Rubrik API determines
the resulting effective SLA.

Remote state verification is disabled because the GraphQL provider cannot
reconcile the nested assignment input against the folder or tag query
response. Changes made outside Terraform are not detected by this module.
