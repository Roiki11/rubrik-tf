# NAS Cloud Direct Protection

Resolves existing NAS Cloud Direct shares by exact share name and parent
system name, then assigns an existing Rubrik SLA Domain to each share. It does
not add shares to a system; configure the NAS appliance and wait for Rubrik's
asynchronous system import to discover them first. The caller must configure
the `sullivtr/graphql` provider.

```hcl
module "nas_cloud_direct_protection" {
  source = "./modules/nas-cloud-direct-protection"

  shares = {
    production_exports = {
      name        = "/production"
      system_name = "nas-cloud-direct.example.com"
    }
  }
  sla_ids = {
    production_exports = "00000000-0000-0000-0000-000000000000"
  }
}
```

Each share/system name pair must resolve to exactly one Cloud Direct share.
The returned `share_ids` map contains the Rubrik IDs by Terraform key.
Removing a share entry unassigns protection (`doNotProtect`) but does not
delete the share, snapshots, or registered system. The SLA Domain must include
`NCD_OBJECT_TYPE`. Share lookup and protection require the registered system
and shares to be visible in Rubrik; asynchronous imports may take time to
complete. `sla_ids` maps each Terraform share key to an SLA Domain UUID.
