variable "vm_names" {
  description = "Exact Rubrik inventory names of the vSphere VMs to protect. Each name must resolve to exactly one VM."
  type        = set(string)
}

variable "sla_ids" {
  description = "SLA Domain IDs keyed by exact vSphere VM name."
  type        = map(string)
  default     = {}
}
