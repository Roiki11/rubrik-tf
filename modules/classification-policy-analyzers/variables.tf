variable "analyzers" {
  description = "Custom sensitive-data analyzers keyed by stable Terraform names. analyzer_type must be a Rubrik AnalyzerTypeEnum value; risk values are HIGH_RISK, MEDIUM_RISK, LOW_RISK, NO_RISK, or UNKNOWN_RISK; rule_types values are STRUCTURED or UNSTRUCTURED."
  type = map(object({
    name                          = string
    analyzer_type                 = string
    risk                          = string
    rule_types                    = optional(set(string), [])
    dictionary                    = optional(set(string), [])
    dictionary_csv                = optional(string)
    structured_dictionary         = optional(set(string), [])
    regex                         = optional(string)
    key_regex                     = optional(string)
    structured_value_regex        = optional(string)
    structured_dictionary_csv     = optional(string)
    structured_key_dictionary     = optional(set(string), [])
    structured_key_dictionary_csv = optional(string)
    exclude_field_name_pattern    = optional(string)
    exclude_path_pattern          = optional(string)
    exclude_value_regex           = optional(string)
    proximity_distance            = optional(number)
    proximity_keywords_regex      = optional(string)
    tag_id                        = optional(number)
    analyzer_risk_instance = optional(object({
      analyzer_id  = string
      risk         = string
      risk_version = number
    }))
    is_inactive = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for analyzer in values(var.analyzers) :
      length(trimspace(analyzer.name)) > 0 &&
      length(trimspace(analyzer.analyzer_type)) > 0 &&
      contains(["HIGH_RISK", "MEDIUM_RISK", "LOW_RISK", "NO_RISK", "UNKNOWN_RISK"], analyzer.risk) &&
      alltrue([for rule_type in analyzer.rule_types : contains(["STRUCTURED", "UNSTRUCTURED"], rule_type)])
    ])
    error_message = "Analyzers require a non-empty name and analyzer_type; risk must be HIGH_RISK, MEDIUM_RISK, LOW_RISK, NO_RISK, or UNKNOWN_RISK; rule_types may contain STRUCTURED and/or UNSTRUCTURED."
  }
}

variable "policies" {
  description = "Classification policies keyed by stable Terraform names. mode must be DISCOVERY or COMPLIANCE; color_enum must be a Rubrik ClassificationPolicyColor value."
  type = map(object({
    name              = string
    description       = optional(string, "")
    mode              = optional(string, "DISCOVERY")
    color_enum        = optional(string, "COLOR_006")
    analyzer_ids      = optional(set(string), [])
    analyzer_keys     = optional(set(string), [])
    document_type_ids = optional(set(string), [])
    object_ids        = optional(set(string), [])
    object_root_ids   = optional(set(string), [])
    cluster_ids       = optional(set(string), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for policy in values(var.policies) :
      contains(["DISCOVERY", "COMPLIANCE"], policy.mode)
    ])
    error_message = "Policy mode must be DISCOVERY or COMPLIANCE."
  }

  validation {
    condition = alltrue([
      for policy in values(var.policies) :
      length(trimspace(policy.name)) > 0
    ])
    error_message = "Every classification policy requires a non-empty name."
  }
}
