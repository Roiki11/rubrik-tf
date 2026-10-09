resource "graphql_mutation" "custom_analyzer" {
  for_each = var.analyzers

  mutation_variables = {
    analyzerRiskInstance = jsonencode(each.value.analyzer_risk_instance == null ? null : {
      analyzerId  = each.value.analyzer_risk_instance.analyzer_id
      risk        = each.value.analyzer_risk_instance.risk
      riskVersion = each.value.analyzer_risk_instance.risk_version
    })
    analyzerType               = jsonencode(each.value.analyzer_type)
    dictionary                 = jsonencode(sort(tolist(each.value.dictionary)))
    dictionaryCsv              = jsonencode(each.value.dictionary_csv)
    excludeFieldNamePattern    = jsonencode(each.value.exclude_field_name_pattern)
    excludePathPattern         = jsonencode(each.value.exclude_path_pattern)
    excludeValueRegex          = jsonencode(each.value.exclude_value_regex)
    isInactive                 = jsonencode(each.value.is_inactive)
    keyRegex                   = jsonencode(each.value.key_regex)
    name                       = jsonencode(each.value.name)
    proximityDistance          = jsonencode(each.value.proximity_distance)
    proximityKeywordsRegex     = jsonencode(each.value.proximity_keywords_regex)
    regex                      = jsonencode(each.value.regex)
    risk                       = jsonencode(each.value.risk)
    ruleTypes                  = jsonencode(sort(tolist(each.value.rule_types)))
    structuredDictionary       = jsonencode(sort(tolist(each.value.structured_dictionary)))
    structuredDictionaryCsv    = jsonencode(each.value.structured_dictionary_csv)
    structuredKeyDictionary    = jsonencode(sort(tolist(each.value.structured_key_dictionary)))
    structuredKeyDictionaryCsv = jsonencode(each.value.structured_key_dictionary_csv)
    structuredValueRegex       = jsonencode(each.value.structured_value_regex)
    tagId                      = jsonencode(each.value.tag_id)
  }

  read_query_variables = {}

  compute_mutation_keys = {
    id = "data.createCustomAnalyzer.id"
  }
  compute_from_create = true

  create_mutation = file("${path.module}/../../gql_files/mutation-create-custom-analyzer-managed.graphql")
  update_mutation = file("${path.module}/../../gql_files/mutation-update-custom-analyzer-managed.graphql")
  delete_mutation = file("${path.module}/../../gql_files/mutation-deactivate-custom-analyzer-managed.graphql")
  read_query      = file("${path.module}/../../gql_files/query-custom-analyzer-managed.graphql")

  enable_remote_state_verification = false
}

locals {
  policy_analyzer_ids = {
    for key, policy in var.policies :
    key => concat(
      sort(tolist(policy.analyzer_ids)),
      [for analyzer_key in sort(tolist(policy.analyzer_keys)) : graphql_mutation.custom_analyzer[analyzer_key].computed_update_operation_variables.id]
    )
  }
}

resource "graphql_mutation" "classification_policy" {
  for_each = var.policies

  mutation_variables = {
    name            = jsonencode(each.value.name)
    description     = jsonencode(each.value.description)
    analyzerIds     = jsonencode(local.policy_analyzer_ids[each.key])
    colorEnum       = jsonencode(each.value.color_enum)
    documentTypeIds = jsonencode(sort(tolist(each.value.document_type_ids)))
    mode            = jsonencode(each.value.mode)
  }

  read_query_variables = {}

  compute_mutation_keys = {
    id = "data.createPolicy.id"
  }
  compute_from_create = true

  create_mutation = file("${path.module}/../../gql_files/mutation-create-classification-policy-managed.graphql")
  update_mutation = file("${path.module}/../../gql_files/mutation-update-classification-policy-managed.graphql")
  delete_mutation = file("${path.module}/../../gql_files/mutation-deactivate-classification-policy-managed.graphql")
  read_query      = file("${path.module}/../../gql_files/query-classification-policy-managed.graphql")

  enable_remote_state_verification = false
}

resource "graphql_mutation" "policy_object_assignment" {
  for_each = {
    for key, policy in var.policies :
    key => policy
    if length(policy.object_ids) + length(policy.object_root_ids) + length(policy.cluster_ids) > 0
  }

  mutation_variables = {
    policyIds     = jsonencode([graphql_mutation.classification_policy[each.key].computed_update_operation_variables.id])
    objectIds     = jsonencode(sort(tolist(each.value.object_ids)))
    objectRootIds = jsonencode(sort(tolist(each.value.object_root_ids)))
    clusterIds    = jsonencode(sort(tolist(each.value.cluster_ids)))
  }

  delete_mutation_variables = {
    policyIds     = jsonencode([graphql_mutation.classification_policy[each.key].computed_update_operation_variables.id])
    objectIds     = jsonencode(sort(tolist(each.value.object_ids)))
    objectRootIds = jsonencode(sort(tolist(each.value.object_root_ids)))
    clusterIds    = jsonencode(sort(tolist(each.value.cluster_ids)))
    runAsync      = "true"
  }

  read_query_variables  = {}
  compute_mutation_keys = {}
  force_replace         = true

  create_mutation = file("${path.module}/../../gql_files/mutation-add-policy-objects.graphql")
  update_mutation = file("${path.module}/../../gql_files/mutation-add-policy-objects.graphql")
  delete_mutation = file("${path.module}/../../gql_files/mutation-remove-policy-objects.graphql")
  read_query      = file("${path.module}/../../gql_files/query-empty.graphql")

  enable_remote_state_verification = false
}
