# Rubrik Sensitive Data Discovery

Queries Rubrik sensitive-data discovery results and the counts of objects
assigned to discovery policies, unassigned objects, and unsupported objects.
This is a read-only reporting module; discovery is configured by assigning
objects to active classification policies in `DISCOVERY` mode. It does not
start a scan directly.

```hcl
module "sensitive_data_discovery" {
  source = "./modules/sensitive-data-discovery"

  enabled = true
  summary_input = {
    includeBreakdown = true
  }
}
```

`summary_input` is passed through as `SensitiveDataSummaryInput`. Its optional
fields are `filter` (an `AccessFilter`) and `includeBreakdown` (a boolean).
Set `enabled = false` to skip the GraphQL queries; both outputs are then
`null`. The calling configuration must configure the `sullivtr/graphql`
provider with an identity authorized to query data governance results.
