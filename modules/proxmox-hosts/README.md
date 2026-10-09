# Rubrik Proxmox Host Configuration

Manages API-token and CA-certificate configuration for existing Rubrik
Proxmox environments. The available GraphQL API supports updating an
environment but does not expose a mutation to register a new Proxmox
environment or node; onboard the environment in Rubrik before using this
module. The caller must configure the `sullivtr/graphql` provider.

```hcl
module "proxmox_hosts" {
  source = "./modules/proxmox-hosts"

  hosts = {
    production = {
      environment_id = "00000000-0000-0000-0000-000000000000"
      api_token      = var.proxmox_api_token
      ca_certs       = var.proxmox_ca_certs
    }
  }
}
```

At least one of `api_token` or `ca_certs` is required for each environment.
The token is sensitive configuration and is stored in Terraform state, so
protect the state backend. Removing an entry does not unregister the
environment or revert the credentials; Rubrik's exposed API has no
unregister operation.
