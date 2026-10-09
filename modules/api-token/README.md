# Rubrik API token credentials

Rubrik Security Cloud issues OAuth access tokens through the service account's
`accessTokenUri`; it does not expose a GraphQL mutation for minting those
short-lived bearer tokens. The `sullivtr/graphql` provider only executes
GraphQL operations, so this provider cannot safely fetch or refresh an OAuth
access token.

Use the `service-account` module to create and manage the long-lived
`clientId`, `clientSecret`, and `accessTokenUri` credentials. Exchange those
credentials for an access token in your deployment runtime, not in Terraform:
access tokens expire, and Terraform state is not an appropriate token cache.

The root configuration in this repository does not accept a raw
`rubrik_api_token` input. It resolves that credential from HashiCorp Vault
through the required `vault_credential_refs.rubrik_api_token` entry. For a
direct reusable-module caller, configure the GraphQL provider with a
currently valid bearer token from that caller's secret manager or runtime;
do not put the token in version-controlled Terraform files. The token must
remain valid for the duration of the Terraform operation.
