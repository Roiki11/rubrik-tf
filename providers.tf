provider "graphql" {
  url = var.rubrik_graphql_url

  headers = {
    Authorization = "Bearer ${local.vault_api_token}"
  }
}

provider "vault" {}
