terraform {
  # Ephemeral resources require Terraform 1.10 or later.
  required_version = ">= 1.10.0"

  required_providers {
    graphql = {
      source  = "sullivtr/graphql"
      version = ">= 2.4.0, < 3.0.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 4.0.0, < 6.0.0"
    }
  }
}
