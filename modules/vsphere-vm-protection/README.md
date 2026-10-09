# Rubrik vSphere VM Protection

This module assigns an existing Rubrik SLA Domain to each vSphere VM ID in
`vm_ids`, using the `graphql_mutation` resource from
[`sullivtr/graphql`](https://registry.terraform.io/providers/sullivtr/graphql/latest).

The module expects the calling configuration to configure the `graphql`
provider. It uses the operation files in the repository's `gql_files/`
directory:

- `assign-sla.graphql` assigns or removes protection.
- `vsphere-vm-by-id.graphql` reads each VM after the mutation.

## Example

At the repository root, set the Rubrik API endpoint and token in the
`graphql` provider configuration, then supply the VM and SLA IDs:

```hcl
module "vsphere_vm_protection" {
  source = "./modules/vsphere-vm-protection"

  vm_ids = [
    "11111111-1111-1111-1111-111111111111",
    "22222222-2222-2222-2222-222222222222",
  ]
  sla_id = "00000000-0000-0000-0000-000000000000"
}
```

`terraform.tfvars.example` shows the root configuration's input format. Copy
it to `terraform.tfvars` and replace the example values, or provide the
variables through `TF_VAR_*` environment variables. Keep API tokens out of
version control.

## Lifecycle

- Create and update assign the specified SLA Domain with
  `slaDomainAssignType = "protectWithSlaId"`.
- Destroy assigns `doNotProtect` to the VM. It does not delete the VM, SLA
  Domain, or existing snapshots.
- The SLA Domain must already exist and be compatible with the selected
  workloads.

The GraphQL provider's mutation resource cannot reconcile this nested
assignment input against the VM query response, so remote state verification
is disabled for these resources. Terraform applies configured changes, but
does not detect an out-of-band change to a VM's SLA assignment.
