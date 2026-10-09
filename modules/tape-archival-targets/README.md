# Rubrik Tape Archival Targets

Creates and manages tape archival targets and tape reader targets on Rubrik
clusters. The caller must configure the `sullivtr/graphql` provider.

```hcl
module "tape_archival_targets" {
  source = "./modules/tape-archival-targets"

  targets = {
    primary = {
      cluster_uuid            = "00000000-0000-0000-0000-000000000000"
      destination_folder_name = "RubrikArchive"
      encryption_password     = var.tape_encryption_password
      host_name               = "qstar.example.com"
      host_port               = 111
      integral_volume_name    = "TAPE01"
      name                    = "Primary tape"
      password                = var.qstar_password
      username                = "rubrik-archive"
    }
  }

  reader_targets = {}
}
```

Reader targets accept the same connection and location fields plus optional
`archival_data_source_ids` and required `reader_retrieval_method`:
`OBJECT_LIST_AND_DETAILS`, `OBJECT_LIST_ONLY`, or
`SPECIFIC_OBJECT_LIST_AND_DETAILS`.

Tape credentials and encryption passwords are sensitive inputs but are stored
in Terraform state. Protect the state backend. Rubrik exposes no delete
mutation for tape targets, so removing a Terraform entry preserves the target.
The API's update mutation only supports the target name, host, port, username,
and password; initial volume, folder, and encryption settings cannot be
changed through this API. Changes to unsupported update fields are not
applied remotely; recreate or change these targets through Rubrik-supported
operations instead.
