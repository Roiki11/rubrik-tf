# Rubrik Classification Policies and Analyzers

Manages custom analyzers, classification policies, and policy-to-object
assignments through the Rubrik GraphQL API. Use policy mode `DISCOVERY` to
configure sensitive-data discovery, or `COMPLIANCE` where appropriate.

```hcl
module "classification" {
  source = "./modules/classification-policy-analyzers"

  analyzers = {
    internal_reference = {
      name          = "Internal reference"
      analyzer_type = "REGEX"
      risk          = "HIGH_RISK"
      rule_types    = ["STRUCTURED", "UNSTRUCTURED"]
      regex         = "REF-[0-9]{8}"
    }
  }

  policies = {
    finance_discovery = {
      name          = "Finance discovery"
      description   = "Discover finance-sensitive data."
      mode          = "DISCOVERY"
      analyzer_keys = ["internal_reference"]
      object_ids    = ["00000000-0000-0000-0000-000000000000"]
    }
  }
}
```

Analyzer `analyzer_type` values must be Rubrik `AnalyzerTypeEnum` members, such
as `REGEX` or `KEYWORD`. `risk` supports `HIGH_RISK`, `MEDIUM_RISK`,
`LOW_RISK`, `NO_RISK`, or `UNKNOWN_RISK`; `rule_types` supports `STRUCTURED`
and `UNSTRUCTURED`. Analyzer dictionaries and regular expressions are passed
to the API as configured. `analyzer_keys` refer to analyzers managed by this
module; `analyzer_ids` can refer to existing Rubrik analyzers.

Policy assignments accept Rubrik hierarchy IDs in `object_ids`, supported
root IDs in `object_root_ids`, and CDM cluster IDs in `cluster_ids`. Each
assignment is removed when the Terraform resource is removed or replaced.
Removing a policy or analyzer deactivates it; Rubrik exposes deactivation
rather than hard deletion through these GraphQL mutations. Policy assignment
and deactivation can run asynchronously, so API completion may lag Terraform.

The module does not start an ad-hoc discovery run. Rubrik discovers data for
objects assigned to active classification policies according to its platform
workflow. Use the `sensitive-data-discovery` module to query discovery
summaries and object counts.
