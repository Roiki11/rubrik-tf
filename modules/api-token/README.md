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

Configure the GraphQL provider with a currently valid bearer token using
`rubrik_api_token`. Supply it through a secret manager or `TF_VAR_rubrik_api_token`;
do not commit it to `terraform.tfvars`.
