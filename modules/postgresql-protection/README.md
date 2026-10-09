# Rubrik PostgreSQL Protection

Assigns an existing SLA Domain to each PostgreSQL database cluster ID in
`database_cluster_ids`. The calling configuration must configure the
`sullivtr/graphql` provider.

```hcl
module "postgresql_protection" {
  source = "./modules/postgresql-protection"

  database_cluster_ids = [
    "33333333-3333-3333-3333-333333333333",
  ]
  sla_id = "00000000-0000-0000-0000-000000000000"
}
```

The module uses `gql_files/assign-sla.graphql` to assign protection and to
remove the assignment on destroy, and
`gql_files/postgresql-db-cluster-by-id.graphql` to read the cluster.
Destroying a Terraform resource unassigns protection; it does not remove the
PostgreSQL cluster or its snapshots.

Remote state verification is disabled because the GraphQL provider cannot
reconcile the nested SLA assignment input against the cluster query response.
Out-of-band SLA assignment changes are therefore not detected.
