# Rubrik Kubernetes Protection

Assigns an existing Rubrik SLA Domain to Kubernetes clusters and Kubernetes
protection sets. Names are matched exactly and must uniquely resolve in
Rubrik. Either input set can be empty. The caller must configure the
`sullivtr/graphql` provider.

```hcl
module "kubernetes_protection" {
  source = "./modules/kubernetes-protection"

  cluster_names        = ["production-k8s"]
  protection_set_names = ["production-apps"]
  namespaces = {
    production_default = {
      cluster_name   = "production-k8s"
      namespace_name = "default"
    }
  }
  sla_id               = "00000000-0000-0000-0000-000000000000"
}
```

The module resolves cluster, namespace, and protection-set IDs through
paginated GraphQL queries. Namespaces are scoped by their cluster name so that
duplicate namespace names across clusters are supported. It uses
`assign-sla.graphql` for protection changes. Removing a resource from
Terraform unassigns its SLA; it does not delete the cluster, namespace,
protection set, or snapshots. A cluster referenced only by a namespace entry
is used to scope the namespace lookup and is not itself assigned an SLA.
Because the GraphQL provider cannot compare the assignment mutation with
Rubrik's nested SLA read result, remote state verification is disabled.
