terraform {
  required_providers {
    graphql = {
      source  = "sullivtr/graphql"
      version = ">= 2.4.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 4.0.0, < 6.0.0"
    }
  }
}

provider "graphql" {
  url = var.rubrik_graphql_url

  headers = {
    Authorization = "Bearer ${local.vault_credentials["rubrik_api_token"]}"
  }
}

provider "vault" {}
