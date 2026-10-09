# Rubrik Service Account and API Credentials

Creates, updates, and deletes a Rubrik service account and exposes its OAuth
client ID, client secret, and access-token URI. The caller must configure the
`sullivtr/graphql` provider with an already valid Rubrik API bearer token and
grant permission to manage service accounts.

```hcl
module "automation_service_account" {
  source = "./modules/service-account"

  name        = "Terraform automation"
  description = "Managed by Terraform"
  role_ids = [
    "00000000-0000-0000-0000-000000000000",
  ]
}
```

The OAuth client secret is returned only when Rubrik creates or rotates the
service-account credentials. Terraform keeps it in state; use an encrypted,
access-controlled remote backend. The `client_secret` module output is
sensitive, but sensitivity does not encrypt state. The GraphQL provider's
computed variable map containing the secret is not marked sensitive by the
provider, so restrict access to plans, state, and Terraform logs as well.

The provider does not expose a reversible role-update operation. Changes to
the account's name, description, or roles replace the account, which invalidates
its old client credentials. Plan and apply those changes accordingly.

Rubrik issues short-lived bearer tokens through the returned `access_token_uri`.
Use a secret manager or runtime OAuth client to exchange the credentials for
bearer tokens; do not persist expiring access tokens in Terraform state. See
`modules/api-token/README.md`.
