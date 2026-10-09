# Rubrik Proxmox Protection

Assigns an existing Rubrik SLA Domain to Proxmox environments, clusters,
nodes, or virtual machines. Each object is addressed by an exact inventory
name and its Rubrik managed-object type. This type-qualified lookup allows
same-named objects of different types while requiring exactly one matching
object of the requested type. The caller must configure the
`sullivtr/graphql` provider.

```hcl
module "proxmox_protection" {
  source = "./modules/proxmox-protection"

  objects = {
    app_vm = {
      name        = "application-01"
      object_type = "PROXMOX_VIRTUAL_MACHINE"
    }
    cluster = {
      name        = "production"
      object_type = "PROXMOX_CLUSTER"
    }
  }
  sla_ids = {
    "object:app_vm" = "00000000-0000-0000-0000-000000000000"
    "object:cluster" = "11111111-1111-1111-1111-111111111111"
  }
}
```

The module uses Rubrik's paginated hierarchy lookup and the shared SLA
assignment mutation. Removing a Terraform entry unassigns protection; it does
not remove the Proxmox object or its snapshots. Remote state verification is
disabled because the GraphQL provider cannot reconcile the nested SLA
assignment mutation against the generic hierarchy-object read response.
`sla_ids` uses `object:<Terraform object key>` entries.
