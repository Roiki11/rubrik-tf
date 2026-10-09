variable "enabled" {
  description = "Whether to query sensitive-data discovery summaries and object counts."
  type        = bool
  default     = true
}

variable "summary_input" {
  description = "SensitiveDataSummaryInput passed to Rubrik; accepts optional filter and includeBreakdown fields."
  type        = any
  default     = { includeBreakdown = true }
}
