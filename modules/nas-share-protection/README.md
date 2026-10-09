# Rubrik NAS Share Protection

Assigns an existing Rubrik SLA Domain to each existing NAS share ID in
`share_names`, resolving each exact name to a Rubrik ID before assignment. The
calling configuration must configure the `sullivtr/graphql`
provider. NAS shares must already be discovered or manually registered in
Rubrik; this module does not add or remove NAS shares.

```hcl
module "nas_share_protection" {
  source = "./modules/nas-share-protection"

  share_names = [
    "engineering-nfs",
  ]
  sla_id = "00000000-0000-0000-0000-000000000000"
}
```

The module uses `gql_files/lookup-nas-share-by-name.graphql` to resolve the
share's Rubrik object ID, `gql_files/assign-sla.graphql` to assign or remove
protection, and `gql_files/query-nas-share.graphql` to read each share.

Destroying a protection resource sets the share to `doNotProtect`; it does not
delete the NAS share or its snapshots. The SLA Domain must support NAS share
objects. Remote state verification is disabled because the provider cannot
reconcile the nested SLA assignment input against the share query response.
Each exact share name must resolve to exactly one object in Rubrik. Missing or
ambiguous names fail during planning.
