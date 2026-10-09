# Rubrik vSphere Server Registration

Registers vCenter Servers and standalone ESXi hosts with a Rubrik cluster
through `createVsphereVcenter`. Set `is_standalone_host = true` for a
standalone host. The caller must configure the `sullivtr/graphql` provider.

```hcl
module "vsphere_servers" {
  source = "./modules/vsphere-server-registration"

  servers = {
    vcenter = {
      cluster_uuid = "00000000-0000-0000-0000-000000000000"
      hostname     = "vcenter.example.com"
      username     = "rubrik-user@example.com"
      password     = var.vcenter_password
    }
    esxi_standalone = {
      cluster_uuid       = "00000000-0000-0000-0000-000000000000"
      hostname           = "esxi-01.example.com"
      username           = "root"
      password           = var.esxi_password
      is_standalone_host = true
    }
  }
}
```

Optional per-server fields are `ca_certs`, `should_enable_hot_add_proxy_onprem`,
`conflict_resolution_authz`
(`VCENTER_CONFIG_V2_CONFLICT_RESOLUTION_AUTHZ_ALLOW_AUTO_CONFLICT_RESOLUTION`
or
`VCENTER_CONFIG_V2_CONFLICT_RESOLUTION_AUTHZ_NO_CONFLICT_RESOLUTION`),
`org_network_id`, and
`is_compute_visibility_filter_disabled` where supported by the target Rubrik
version.

Registration credentials are sensitive Terraform inputs but are stored in
Terraform state. Protect the state backend. Changes to a server definition
replace the registration because the API has no update-credentials mutation;
destroying the Terraform resource calls Rubrik's vCenter unregister mutation.
Unregistering can affect protection and inventory visibility for workloads
under that server.
