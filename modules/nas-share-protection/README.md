# Rubrik NAS Share Protection

Registers multiple Generic NAS or PowerScale servers, optionally adds
manually configured shares to their selected server, and assigns SLA Domains
to those shares. It can also protect already-discovered shares by exact name.
The calling configuration must configure the `sullivtr/graphql` provider.

```hcl
module "nas_share_protection" {
  source = "./modules/nas-share-protection"

  nas_servers = {
    generic = {
      cluster_uuid = "00000000-0000-0000-0000-000000000000"
      hostname     = "nas.example.com"
      vendor_type  = "NAS_VENDOR_TYPE_GENERIC"
      generic_parameters = {
        has_nfs_support = true
        has_smb_support = false
      }
    }
  }
  nas_shares = {
    engineering = {
      export_point   = "/engineering"
      share_type     = "CREATE_NAS_SHARE_INPUT_SHARE_TYPE_NFS"
      nas_server_key = "generic"
    }
  }
  share_names = ["already-discovered-share"]
  sla_ids = {
    "configured:engineering" = "00000000-0000-0000-0000-000000000000"
    "existing:already-discovered-share" = "11111111-1111-1111-1111-111111111111"
  }
}
```

For a PowerScale (Isilon) server, set `vendor_type` to
`NAS_VENDOR_TYPE_ISILON`, supply `api_credentials` with `api_username` and
`api_password`, and optionally configure `is_isilon_changelist_enabled`,
`smb_credentials`, and shares.

```hcl
nas_servers = {
  powerscale = {
    cluster_uuid = "00000000-0000-0000-0000-000000000000"
    hostname     = "powerscale.example.com"
    vendor_type  = "NAS_VENDOR_TYPE_ISILON"
    api_credentials = {
      api_username = "rubrik-api-user"
      api_password = var.powerscale_api_password
    }
    is_isilon_changelist_enabled = true
  }
}
```

`sla_ids` keys use `existing:<share name>` for discovered shares and
`configured:<share key>` for manually added shares.

The module uses `gql_files/mutation-register-nas-system-managed.graphql` to
register the server, `gql_files/mutation-add-nas-share-managed.graphql` to add
shares, and `gql_files/lookup-nas-share-by-name.graphql` to resolve discovered
shares. It uses `gql_files/assign-sla.graphql` to protect/unprotect shares and
`gql_files/query-nas-share.graphql` to read them.

Destroying a protection resource sets the share to `doNotProtect`; it does not
unregister the NAS server, remove manually configured shares, or delete
snapshots. Removing a NAS server/share configuration from Terraform therefore
leaves it registered in Rubrik. The SLA Domain must support NAS objects.

`registerNasSystem` and manual share addition are asynchronous/server-version
dependent. Manual share registration requires Rubrik v8.1 or later. Exact
share-name lookup must return exactly one object. Keep credentials out of
version control and use an encrypted, access-controlled Terraform state
backend; the GraphQL provider can retain mutation variables in state.
Removing a server or manually added share from Terraform preserves the
underlying Rubrik object. Re-adding the same declaration may be rejected as a
duplicate, so retain the configuration or reconcile the existing object
manually.

Remote state verification is disabled for SLA assignments because the
provider cannot reconcile their nested input against the share query response.
