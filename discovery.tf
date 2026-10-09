module "classification_policy_analyzers" {
  source = "./modules/classification-policy-analyzers"

  analyzers = var.classification_analyzers
  policies  = var.classification_policies
}

module "sensitive_data_discovery" {
  source = "./modules/sensitive-data-discovery"

  enabled       = var.sensitive_data_discovery_enabled
  summary_input = var.sensitive_data_summary_input
}
