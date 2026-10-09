variable "name" {
  description = "Name of the Rubrik role granting inventory visibility."
  type        = string

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "The inventory-role name must be non-empty."
  }
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

  validation {
    condition     = alltrue([for name in var.vsphere_vm_names : length(trimspace(name)) > 0])
    error_message = "Every vSphere VM name must be non-empty."
  }
}

variable "vsphere_folder_names" {
  description = "Exact names of vSphere folders whose Rubrik inventory IDs should be looked up."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for name in var.vsphere_folder_names : length(trimspace(name)) > 0])
    error_message = "Every vSphere folder name must be non-empty."
  }
}

variable "postgresql_db_cluster_names" {
  description = "Exact names of PostgreSQL database clusters whose Rubrik inventory IDs should be looked up."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for name in var.postgresql_db_cluster_names : length(trimspace(name)) > 0])
    error_message = "Every PostgreSQL database cluster name must be non-empty."
  }
}

variable "nas_share_names" {
  description = "Exact names of existing NAS shares whose Rubrik inventory IDs should be looked up."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for name in var.nas_share_names : length(trimspace(name)) > 0])
    error_message = "Every NAS share name must be non-empty."
  }
}
