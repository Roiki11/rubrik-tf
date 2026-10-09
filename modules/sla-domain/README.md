# Rubrik SLA Domain

Creates and manages a Rubrik SLA Domain using the `sullivtr/graphql` provider.
The caller must configure the provider. The module supports the SLA name,
description, object types, and snapshot schedule; provide schedule fields in
the shape accepted by Rubrik's `GlobalSnapshotScheduleInput`.

```hcl
module "postgresql_sla" {
  source = "./modules/sla-domain"

  name        = "PostgreSQL daily"
  description = "Daily protection for PostgreSQL clusters"
  object_types = [
    "POSTGRES_DB_CLUSTER_OBJECT_TYPE",
  ]
  snapshot_schedule = {
    daily = {
      basicSchedule = {
        frequency     = 1
        retention     = 30
        retentionUnit = "DAYS"
      }
    }
  }
}
```

The module uses `gql_files/create-global-sla-managed.graphql`,
`gql_files/update-global-sla-managed.graphql`,
`gql_files/mutation-delete-global-sla.graphql`, and
`gql_files/query-sla-domain.graphql`. Destroy deletes the SLA Domain. Rubrik
may reject deletion while the domain is assigned to protected workloads or
otherwise in use.

The provider's generic GraphQL mutation resource does not reconcile mutation
inputs against a read response, so remote state verification is disabled.
Terraform still reads the SLA Domain and uses its ID for updates and deletes.
