# NAS Cloud Direct Systems

Registers NAS appliances as Rubrik NAS Cloud Direct systems with
`addCloudDirectSystem`. Registration runs asynchronously and returns a job ID;
the system may not be ready for share lookup or protection until Rubrik's
import job completes. The caller must configure the `sullivtr/graphql`
provider.

```hcl
module "nas_cloud_direct_systems" {
  source = "./modules/nas-cloud-direct-systems"

  systems = {
    generic_nfs_production = {
      cluster_id                    = "00000000-0000-0000-0000-000000000000"
      host                          = "nas-cloud-direct.example.com"
      system_type                   = "GENERIC_NFS"
      skip_service_account_creation = false
      verify_ssl                    = true
    }
  }
}
```

`system_type` accepts the Rubrik `CloudDirectNasVendorType` values listed in
the input validation, including `AZURE_FILES`, `FSXN`, `GENERIC_NFS`,
`GENERIC_NFS4`, `GENERIC_S3`, `GENERIC_SMB`, `ISILON`, `NUTANIX`, `QUMULO`,
and `VAST_DATA`. Use only values supported by the target Rubrik schema.

Optional fields are `username`, `password`, `region`, client certificate
fields (`certificate_data`, `certificate_key_password`, and
`certificate_type` of `PEM` or `PKCS12`), named S3 `creds`, and
`management_info` (`file_system_id` or `private_endpoint`) for the applicable
vendor. Credentials are stored in Terraform state; use an encrypted and
access-controlled state backend.

Rubrik exposes no update or delete mutation for these systems. Removing a
Terraform entry does not unregister the system. Changing registration
configuration attempts the add operation again; do not change an existing
entry unless the Rubrik system has been reconciled manually. Use
`registration_job_ids` to track the asynchronous import, then configure
shares/protection after the system and its shares appear in Rubrik.
