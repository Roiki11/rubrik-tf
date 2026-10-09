variable "name" {
  description = "Name of the Rubrik role granting inventory visibility."
  type        = string
}

variable "description" {
  description = "Description of the Rubrik role granting account-wide inventory visibility."
  type        = string
  default     = "Account-wide read-only access to protectable object inventory."
}

variable "vsphere_vm_names" {
  description = "Exact names of vSphere VMs whose Rubrik inventory IDs should be looked up."
  type        = set(string)
  default     = []
}

variable "vsphere_folder_names" {
  description = "Exact names of vSphere folders whose Rubrik inventory IDs should be looked up."
  type        = set(string)
  default     = []
}

variable "postgresql_db_cluster_names" {
  description = "Exact names of PostgreSQL database clusters whose Rubrik inventory IDs should be looked up."
  type        = set(string)
  default     = []
}

variable "nas_share_names" {
  description = "Exact names of existing NAS shares whose Rubrik inventory IDs should be looked up."
  type        = set(string)
  default     = []
}
