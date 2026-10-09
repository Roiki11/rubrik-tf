variable "shares" {
  description = "Existing NAS Cloud Direct shares to protect, keyed by stable Terraform names and identified by exact share and system names."
  type = map(object({
    name        = string
    system_name = string
  }))
  default = {}
}

variable "sla_ids" {
  description = "SLA Domain IDs keyed by the configured NAS Cloud Direct share key."
  type        = map(string)
  default     = {}
}
