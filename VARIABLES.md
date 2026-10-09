# Terraform variables and module reference

This document describes the root configuration inputs and every input exposed
by the reusable modules under `modules/`. Root inputs are declared in
[`variables.tf`](./variables.tf); each module can also be used directly by
configuring the `sullivtr/graphql` provider in the calling configuration.

Use [`terraform.tfvars.example`](./terraform.tfvars.example) as a starting
point for the root configuration. Supply credentials through a secure input
mechanism rather than committing them to a tfvars file.

## Root configuration inputs

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `rubrik_graphql_url` | `string` | Required | Rubrik Security Cloud GraphQL endpoint URL, for example `https://<tenant>/api/graphql`. |
| `rubrik_api_token` | `string` (sensitive) | Required | Bearer token used by the GraphQL provider. Keep it out of source control and protect Terraform state. |
| `vsphere_vm_names` | `set(string)` | Required | Exact Rubrik inventory names of vSphere VMs. Each name must resolve to one VM. Use `[]` when unused. |
| `vsphere_folder_names` | `set(string)` | Required | Exact Rubrik inventory names of vSphere folders. Each name must resolve to one folder. Use `[]` when unused. |
| `vsphere_tag_ids` | `set(string)` | Required | Rubrik tag UUIDs; each value must match the UUID format. Use `[]` when unused. Tag names are not resolved. |
| `postgresql_db_cluster_names` | `set(string)` | Required | Exact Rubrik inventory names of PostgreSQL database clusters. Each name must resolve to one cluster. Use `[]` when unused. |
| `nas_share_names` | `set(string)` | Required | Exact names of existing/discovered NAS shares. Each name must resolve to one share. Use `[]` when unused. |
| `nas_server` | Object; see below | `null` | Optional NAS server registration. Vendor-specific fields are described in [NAS server inputs](#nas-server-inputs). |
| `nas_shares` | `map(object)`; see below | `{}` | Optional manually configured NAS shares, keyed by stable Terraform names. See [NAS share inputs](#nas-share-inputs). |
| `sla_domain_name` | `string` | Required | Name for the SLA Domain created by the root configuration. |
| `sla_domain_description` | `string` | `null` | Optional SLA Domain description. |
| `sla_domain_object_types` | `set(string)` | Required | At least one Rubrik SLA object-type enum value is required. Values must be supported by the Rubrik API and compatible with the objects assigned to this SLA. See [SLA object types](#sla-object-types). |
| `sla_domain_snapshot_schedule` | `any` | Required | Object matching Rubrik's `GlobalSnapshotScheduleInput`; supports minute, hourly, daily, weekly, monthly, quarterly, and yearly schedules. |
| `sla_domain_archival_specs` | `list(any)` | `[]` | Optional list of Rubrik archival specifications, including archival group, threshold, frequencies, and tiering options. See the [sla-domain module README](./modules/sla-domain/README.md#archive-configuration). |
| `service_account_name` | `string` | Required | Name for the automation service account. |
| `service_account_description` | `string` | `""` | Optional service-account description. |
| `service_account_role_ids` | `set(string)` | `[]` | Additional Rubrik role IDs to grant. The root configuration also grants the managed object-inventory role. |
| `object_inventory_role_name` | `string` | `"Terraform object inventory reader"` | Name for the account-wide inventory-read role managed by the root configuration. |

### Root input example

```hcl
rubrik_graphql_url = "https://<your-rsc-tenant>/api/graphql"
rubrik_api_token   = "<supply securely; do not commit this value>"

vsphere_vm_names            = ["application-01"]
vsphere_folder_names        = ["Production"]
vsphere_tag_ids             = ["66666666-6666-6666-6666-666666666666"]
postgresql_db_cluster_names = ["postgres-production"]
nas_share_names             = ["engineering-nfs"]

sla_domain_name        = "Terraform protection"
sla_domain_description = "Managed by Terraform"
sla_domain_object_types = [
  "VSPHERE_OBJECT_TYPE",
  "POSTGRES_DB_CLUSTER_OBJECT_TYPE",
  "NAS_OBJECT_TYPE",
]
sla_domain_snapshot_schedule = {
  daily = {
    basicSchedule = {
      frequency     = 1
      retention     = 30
      retentionUnit = "DAYS"
    }
  }
}
sla_domain_archival_specs = [
  {
    archivalGroupId = "00000000-0000-0000-0000-000000000000"
    threshold       = 30
    thresholdUnit   = "DAYS"
  }
]

service_account_name        = "Terraform automation"
service_account_description = "Managed by Terraform"
service_account_role_ids    = []
```

For NAS configurations, add `nas_server` and/or `nas_shares` as described
below. Inputs for workloads not in use can be empty sets; `nas_server` can be
`null` and `nas_shares` can be `{}`.

## Reusable module inputs

All names used for inventory lookups are exact names, not partial or
case-insensitive matches. Where a module resolves an inventory name, that name
must match exactly one Rubrik object. The `sla_id` inputs expect the Rubrik SLA
Domain UUID.

### `vsphere-vm-protection`

Source: `./modules/vsphere-vm-protection`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `vm_names` | `set(string)` | Required | Exact names of vSphere VMs; each must resolve to one VM. |
| `sla_id` | `string` | Required | UUID of an existing SLA Domain. |

```hcl
module "vsphere_vm_protection" {
  source = "./modules/vsphere-vm-protection"

  vm_names = ["application-01", "application-02"]
  sla_id   = "00000000-0000-0000-0000-000000000000"
}
```

### `vsphere-container-sla-assignment`

Source: `./modules/vsphere-container-sla-assignment`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `folder_names` | `set(string)` | Required | Exact names of vSphere folders; each must resolve to one folder. Use `[]` if no folders are assigned. |
| `tag_ids` | `set(string)` | Required | Rubrik tag UUIDs. Tag names cannot be resolved by this module. Use `[]` if no tags are assigned. |
| `sla_id` | `string` | Required | UUID of the SLA Domain to assign. |

```hcl
module "vsphere_container_sla_assignments" {
  source = "./modules/vsphere-container-sla-assignment"

  folder_names = ["Production"]
  tag_ids      = ["66666666-6666-6666-6666-666666666666"]
  sla_id       = "00000000-0000-0000-0000-000000000000"
}
```

### `postgresql-protection`

Source: `./modules/postgresql-protection`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `database_cluster_names` | `set(string)` | Required | Exact names of PostgreSQL database clusters; each must resolve to one cluster. |
| `sla_id` | `string` | Required | UUID of the SLA Domain to assign. |

```hcl
module "postgresql_protection" {
  source = "./modules/postgresql-protection"

  database_cluster_names = ["postgres-production"]
  sla_id                 = "00000000-0000-0000-0000-000000000000"
}
```

### `nas-share-protection`

Source: `./modules/nas-share-protection`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `share_names` | `set(string)` | `[]` | Exact names of existing/discovered shares; each must resolve to one share. |
| `nas_server` | Object; see [NAS server inputs](#nas-server-inputs) | `null` | Optional server registration. |
| `nas_shares` | `map(object)`; see [NAS share inputs](#nas-share-inputs) | `{}` | Optional manually added shares on the configured server. |
| `sla_id` | `string` | Required | UUID of the SLA Domain to assign to each managed share. |

```hcl
module "nas_share_protection" {
  source = "./modules/nas-share-protection"

  nas_server = {
    cluster_uuid = "88888888-8888-8888-8888-888888888888"
    hostname     = "nas.example.com"
    vendor_type  = "NAS_VENDOR_TYPE_GENERIC"
    generic_parameters = {
      has_nfs_support = true
      has_smb_support = false
    }
  }
  nas_shares = {
    research = {
      export_point = "/research"
      share_type   = "CREATE_NAS_SHARE_INPUT_SHARE_TYPE_NFS"
    }
  }
  share_names = ["already-discovered-share"]
  sla_id      = "00000000-0000-0000-0000-000000000000"
}
```

#### NAS server inputs

`nas_server` is an object with the following fields:

| Field | Type | Requiredness and allowed values |
|---|---|---|
| `cluster_uuid` | `string` | Required Rubrik cluster UUID. |
| `hostname` | `string` | Required NAS server hostname/address. |
| `vendor_type` | `string` | Required. Exactly `NAS_VENDOR_TYPE_GENERIC` or `NAS_VENDOR_TYPE_ISILON` (PowerScale). |
| `generic_parameters` | Object or `null` | Required for Generic NAS; not the vendor configuration for PowerScale. Fields: `has_nfs_support` and `has_smb_support` (`bool`), optional `nfs_pseudo_fs_prefix` (`string`), optional `smb_credentials` object (`username`, `password`). |
| `api_credentials` | Object or `null` | Required for PowerScale. Required fields: `api_username`, `api_password`; optional `api_certificate`, `certificate_id` strings. |
| `smb_credentials` | Object or `null` | Optional SMB credentials (`username`, `password`), where applicable. |
| `is_isilon_changelist_enabled` | `bool` or `null` | Optional PowerScale changelist setting. |

Example PowerScale server:

```hcl
nas_server = {
  cluster_uuid = "88888888-8888-8888-8888-888888888888"
  hostname     = "powerscale.example.com"
  vendor_type  = "NAS_VENDOR_TYPE_ISILON"
  api_credentials = {
    api_username = "rubrik-api-user"
    api_password = var.powerscale_api_password
  }
  is_isilon_changelist_enabled = true
}
```

#### NAS share inputs

`nas_shares` is a map keyed by a stable Terraform identifier. Each value has:

| Field | Type | Requiredness and allowed values |
|---|---|---|
| `export_point` | `string` | Required NAS export path/share point. |
| `share_type` | `string` | Required. Exactly `CREATE_NAS_SHARE_INPUT_SHARE_TYPE_NFS` or `CREATE_NAS_SHARE_INPUT_SHARE_TYPE_SMB`. |
| `credentials` | Object or `null` | Optional; `username` is required when the object is supplied, and `password` is optional. |

```hcl
nas_shares = {
  engineering = {
    export_point = "/engineering"
    share_type   = "CREATE_NAS_SHARE_INPUT_SHARE_TYPE_NFS"
  }
  team_smb = {
    export_point = "team"
    share_type   = "CREATE_NAS_SHARE_INPUT_SHARE_TYPE_SMB"
    credentials = {
      username = "rubrik-smb-user"
      password = var.nas_smb_password
    }
  }
}
```

NAS credentials are sensitive Terraform inputs, but can still be retained in
Terraform state and provider state. Protect the state backend and avoid storing
credentials in version control. Removing the configuration preserves the
registered NAS server and manually added shares in Rubrik.

### `sla-domain`

Source: `./modules/sla-domain`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `name` | `string` | Required | SLA Domain name. |
| `description` | `string` | `null` | Optional description. |
| `object_types` | `set(string)` | Required; must contain at least one value | Rubrik `SlaObjectType` enum values supported by the API. Use types compatible with the protected workloads. Examples: `VSPHERE_OBJECT_TYPE`, `POSTGRES_DB_CLUSTER_OBJECT_TYPE`, `NAS_OBJECT_TYPE`. This list is illustrative, not exhaustive. |
| `snapshot_schedule` | `any` | Required | Value matching Rubrik's `GlobalSnapshotScheduleInput`, supporting minute, hourly, daily, weekly, monthly, quarterly, and yearly cadences. |
| `archival_specs` | `list(any)` | `[]` | Optional list of Rubrik `ArchivalSpecInput` values passed on create and update. See [archive configuration](./modules/sla-domain/README.md#archive-configuration). |

```hcl
module "rubrik_sla_domain" {
  source = "./modules/sla-domain"

  name         = "Production daily"
  description  = "Daily protection for production workloads"
  object_types = ["VSPHERE_OBJECT_TYPE", "NAS_OBJECT_TYPE"]
  snapshot_schedule = {
    daily = {
      basicSchedule = {
        frequency     = 1
        retention     = 30
        retentionUnit = "DAYS"
      }
    }
  }
  archival_specs = [
    {
      archivalGroupId = "00000000-0000-0000-0000-000000000000"
      threshold       = 30
      thresholdUnit   = "DAYS"
    }
  ]
}
```

#### SLA object types

The module passes `object_types` to Rubrik as values of the GraphQL
`SlaObjectType` enum. Common examples used by this configuration are:

| Value | Workload |
|---|---|
| `VSPHERE_OBJECT_TYPE` | vSphere objects |
| `POSTGRES_DB_CLUSTER_OBJECT_TYPE` | PostgreSQL database clusters |
| `NAS_OBJECT_TYPE` | NAS objects |

The Rubrik API schema for the target cluster is authoritative. Enum members
can vary with API version and available features; use only values accepted by
that schema and supported by the SLA and workloads you intend to protect.

#### Snapshot schedule and archive configuration

The complete schedule cadence fields, time selectors, archive fields, and
examples are documented in the [`sla-domain` module README](./modules/sla-domain/README.md#snapshot-schedule-fields).

### `service-account`

Source: `./modules/service-account`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `name` | `string` | Required | Service-account name. |
| `description` | `string` | `""` | Optional description. |
| `role_ids` | `set(string)` | Required; must contain at least one value | Rubrik role IDs assigned to the account. |

```hcl
module "automation_service_account" {
  source = "./modules/service-account"

  name        = "Terraform automation"
  description = "Managed by Terraform"
  role_ids    = ["44444444-4444-4444-4444-444444444444"]
}
```

The root configuration additionally grants its managed inventory-reader role
to this account. The service-account client secret is an output and should be
handled as sensitive data.

### `object-inventory-role`

Source: `./modules/object-inventory-role`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `name` | `string` | Required | Name of the inventory visibility role. |
| `description` | `string` | `"Account-wide read-only access to protectable object inventory."` | Role description. |

```hcl
module "object_inventory_role" {
  source = "./modules/object-inventory-role"

  name        = "Terraform object inventory reader"
  description = "Read-only visibility of protectable objects"
}
```

## Root outputs

The root configuration exports:

| Output | Description |
|---|---|
| `object_inventory_role_id` | Rubrik ID of the managed inventory-reader role. |
| `nas_server_id` | Registered NAS server ID, or `null` when no server was configured. |
| `service_account_client_id` | OAuth client ID for the service account. |
| `service_account_client_secret` | Sensitive OAuth client secret. |
| `service_account_access_token_uri` | OAuth endpoint used to exchange service-account credentials. |
