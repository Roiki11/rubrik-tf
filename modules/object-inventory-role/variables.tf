variable "name" {
  description = "Name of the Rubrik role granting inventory visibility."
  type        = string
}

variable "description" {
  description = "Description of the Rubrik role granting account-wide inventory visibility."
  type        = string
  default     = "Account-wide read-only access to protectable object inventory."
}
