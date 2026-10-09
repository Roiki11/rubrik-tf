# Rubrik PostgreSQL Protection

Assigns an existing SLA Domain to each PostgreSQL database cluster name in
`database_cluster_names`, resolving each exact name to a Rubrik ID before
assignment. The calling configuration must configure the
`sullivtr/graphql` provider.

```hcl
module "postgresql_protection" {
  source = "./modules/postgresql-protection"

  database_cluster_names = [
    "postgres-production",
  ]
  sla_id = "00000000-0000-0000-0000-000000000000"
}
```

The module uses `gql_files/lookup-postgresql-cluster-by-name.graphql` to
resolve each cluster name to its Rubrik object ID, `gql_files/assign-sla.graphql`
to assign protection and remove the assignment on destroy, and
`gql_files/postgresql-db-cluster-by-id.graphql` to read the cluster. Each exact
cluster name must resolve to exactly one Rubrik object; missing or ambiguous
names fail during planning.
Destroying a Terraform resource unassigns protection; it does not remove the
PostgreSQL cluster or its snapshots.

Remote state verification is disabled because the GraphQL provider cannot
reconcile the nested SLA assignment input against the cluster query response.
Out-of-band SLA assignment changes are therefore not detected.
