# Terraform variables and module reference

This document describes the root configuration inputs and every input exposed
by the reusable modules under `modules/`. Root inputs are declared in
[`variables.tf`](./variables.tf); each module can also be used directly by
configuring the `sullivtr/graphql` provider in the calling configuration.

Use [`terraform.tfvars.example`](./terraform.tfvars.example) as a starting
point for the root configuration. Configure the Vault provider using its
standard environment variables or another supported Vault authentication
method. The root `vault_credential_refs` map maps logical credential names to
HashiCorp Vault KV v2 mount, path, and field names; resource inputs reference
those logical names instead of containing secret values. Fetched values are
marked sensitive, but Terraform state and plans can still contain secrets, so
protect them accordingly.

## Module index

| Module | Purpose |
|---|---|
| [`vsphere-vm-protection`](#vsphere-vm-protection) | Assign an SLA Domain to selected vSphere VMs. |
| [`vsphere-container-sla-assignment`](#vsphere-container-sla-assignment) | Assign an SLA Domain to vSphere folders and tags. |
| [`postgresql-protection`](#postgresql-protection) | Protect PostgreSQL database clusters with an SLA Domain. |
| [`kubernetes-protection`](#kubernetes-protection) | Protect Kubernetes clusters, namespaces, and protection sets. |
| [`proxmox-protection`](#proxmox-protection) | Protect Proxmox environments, clusters, nodes, and VMs. |
| [`nas-share-protection`](#nas-share-protection) | Register NAS servers and shares, and assign SLA protection. |
| [`nas-cloud-direct-systems`](#nas-cloud-direct-systems) | Register NAS Cloud Direct systems. |
| [`nas-cloud-direct-protection`](#nas-cloud-direct-protection) | Resolve NAS Cloud Direct shares and assign SLA protection. |
| [`linux-fileset-protection`](#linux-fileset-protection) | Configure Linux fileset templates and protect filesets. |
| [`sla-domain`](#sla-domain) | Create and manage SLA Domains, schedules, and archive settings. |
| [`service-account`](#service-account) | Manage a Rubrik service account and its assigned roles. |
| [`classification-policy-analyzers`](#classification-policy-analyzers) | Manage custom analyzers, classification policies, and object assignments. |
| [`sensitive-data-discovery`](#sensitive-data-discovery) | Query sensitive-data summaries and discovery object counts. |
| [`object-inventory-role`](#object-inventory-role) | Manage inventory-read access and resolve configured object IDs. |
| [`vsphere-server-registration`](#vsphere-server-registration) | Register vCenter Servers and standalone ESXi hosts. |
| [`proxmox-hosts`](#proxmox-hosts) | Update API-token and CA configuration for existing Proxmox environments. |
| [`tape-archival-targets`](#tape-archival-targets) | Create and update tape archival and reader targets. |

## Root configuration inputs

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `rubrik_graphql_url` | `string` | Required | Rubrik Security Cloud GraphQL endpoint URL, for example `https://<tenant>/api/graphql`. |
| `vault_credential_refs` | `map(object)` | Required | Central mapping of logical credential names to Vault KV v2 `mount`, `path`, and `key` fields. Must include the `rubrik_api_token` alias and every credential alias referenced by configured resources. |
| `vsphere_vm_names` | `set(string)` | Required | Exact Rubrik inventory names of vSphere VMs. Each name must resolve to one VM. Use `[]` when unused. |
| `vsphere_vm_sla_domain_keys` | `map(string)` | `{}` | SLA Domain key for each protected VM, keyed by exact VM name. |
| `vsphere_folder_names` | `set(string)` | Required | Exact Rubrik inventory names of vSphere folders. Each name must resolve to one folder. Use `[]` when unused. |
| `vsphere_folder_sla_domain_keys` | `map(string)` | `{}` | SLA Domain key for each folder, keyed by exact folder name. |
| `vsphere_tag_ids` | `set(string)` | Required | Rubrik tag UUIDs; each value must match the UUID format. Use `[]` when unused. Tag names are not resolved. |
| `vsphere_tag_sla_domain_keys` | `map(string)` | `{}` | SLA Domain key for each tag, keyed by tag UUID. |
| `postgresql_db_cluster_names` | `set(string)` | Required | Exact Rubrik inventory names of PostgreSQL database clusters. Each name must resolve to one cluster. |
| `postgresql_sla_domain_keys` | `map(string)` | `{}` | SLA Domain key for each PostgreSQL cluster, keyed by exact cluster name. |
| `linux_fileset_cluster_uuid` | `string` | `""` | Rubrik CDM cluster UUID used for Linux fileset template and fileset operations; required when Linux templates are configured. |
| `linux_fileset_templates` | `map(object)` | `{}` | Linux template definitions keyed by template name, including include paths and optional excludes, exceptions, scripts, and fileset options. |
| `linux_fileset_assignments` | `map(object)` | `{}` | Linux host/template pairs keyed by stable Terraform identifiers. See the [Linux fileset module README](./modules/linux-fileset-protection/README.md). |
| `linux_fileset_sla_domain_keys` | `map(string)` | `{}` | SLA Domain key for each Linux fileset assignment, keyed by Terraform assignment key. |
| `kubernetes_cluster_names` | `set(string)` | `[]` | Exact Rubrik inventory names of Kubernetes clusters to protect. Each name must resolve to exactly one cluster. |
| `kubernetes_cluster_sla_domain_keys` | `map(string)` | `{}` | SLA Domain key for each Kubernetes cluster, keyed by exact cluster name. |
| `kubernetes_protection_set_names` | `set(string)` | `[]` | Exact Rubrik inventory names of Kubernetes protection sets to protect. Each name must resolve to exactly one protection set. |
| `kubernetes_protection_set_sla_domain_keys` | `map(string)` | `{}` | SLA Domain key for each Kubernetes protection set, keyed by exact protection-set name. |
| `kubernetes_namespaces` | `map(object)` | `{}` | Kubernetes namespaces keyed by stable Terraform keys, each specifying exact `cluster_name` and `namespace_name` values. |
| `kubernetes_namespace_sla_domain_keys` | `map(string)` | `{}` | SLA Domain key for each Kubernetes namespace, keyed by Terraform namespace key. |
| `proxmox_objects` | `map(object)` | `{}` | Proxmox objects keyed by stable Terraform keys. Each object specifies an exact `name` and `object_type`: `PROXMOX_ENVIRONMENT`, `PROXMOX_CLUSTER`, `PROXMOX_NODE`, or `PROXMOX_VIRTUAL_MACHINE`. |
| `proxmox_object_sla_domain_keys` | `map(string)` | `{}` | SLA Domain key for each Proxmox object, keyed by Terraform object key. |
| `nas_share_names` | `set(string)` | Required | Exact names of existing/discovered NAS shares. Each name must resolve to one share. Use `[]` when unused. |
| `nas_share_sla_domain_keys` | `map(string)` | `{}` | SLA Domain key for each existing NAS share, keyed by exact share name. |
| `nas_servers` | `map(object)`; see below | `{}` | NAS server registrations keyed by stable Terraform names. Vendor-specific fields are described in [NAS server inputs](#nas-server-inputs). |
| `nas_shares` | `map(object)`; see below | `{}` | Manually configured NAS shares keyed by stable Terraform names; each specifies `nas_server_key`. See [NAS share inputs](#nas-share-inputs). |
| `nas_configured_share_sla_domain_keys` | `map(string)` | `{}` | SLA Domain key for each manually configured NAS share, keyed by Terraform share key. |
| `nas_cloud_direct_systems` | `map(object)` | `{}` | NAS Cloud Direct systems to register. Registration is asynchronous and returns a job ID. See [NAS Cloud Direct systems](#nas-cloud-direct-systems). |
| `nas_cloud_direct_shares` | `map(object)` | `{}` | Existing Cloud Direct shares keyed by Terraform name and identified by exact share/system names. |
| `nas_cloud_direct_share_sla_domain_keys` | `map(string)` | `{}` | SLA Domain key for each Cloud Direct share, keyed by Terraform share key. |
| `sla_domains` | `map(object)` | Required | SLA Domain definitions keyed by stable Terraform names; each contains a name, object types, snapshot schedule, and optional description/archive specs. See [SLA object types](#sla-object-types). |
| `object_inventory_roles` | `map(object)` | `{}` | Inventory-read roles keyed by stable Terraform names. |
| `service_accounts` | `map(object)` | `{}` | Service accounts keyed by stable Terraform names; each may reference `role_ids` and/or `inventory_role_keys`. |
| `classification_analyzers` | `map(object)` | `{}` | Custom analyzers keyed by stable names. Supports analyzer type, risk, structured/unstructured rules, dictionaries, regexes, exclusions, and optional tagging. |
| `classification_policies` | `map(object)` | `{}` | Classification policies keyed by stable names, including analyzer IDs/keys and target hierarchy/object/root/cluster IDs. `mode` accepts `DISCOVERY` or `COMPLIANCE`. |
| `sensitive_data_discovery_enabled` | `bool` | `false` | Enable read-only queries for sensitive-data summary and discovery object counts. |
| `sensitive_data_summary_input` | `any` | `{ includeBreakdown = true }` | `SensitiveDataSummaryInput` passed to Rubrik, including optional `filter` and `includeBreakdown`. |
| `vsphere_servers` | `map(object)` | `{}` | vCenter/standalone ESXi registration definitions. See [vSphere server registration](#vsphere-server-registration). |
| `proxmox_hosts` | `map(object)` | `{}` | Existing Proxmox environment IDs and API token/CA configuration. See [Proxmox hosts](#proxmox-hosts). |
| `tape_archival_targets` | `map(object)` | `{}` | Tape target connection, credential, volume, and encryption settings. See [tape archival targets](#tape-archival-targets). |
| `tape_reader_targets` | `map(object)` | `{}` | Tape reader target settings, including retrieval method. See [tape archival targets](#tape-archival-targets). |

### Root input example

The complete, validated multi-resource example is in
[`terraform.tfvars.example`](./terraform.tfvars.example). Each protected
object is assigned an SLA Domain by a keyed `*_sla_domain_keys` map. The map
keys are the corresponding exact inventory name or stable Terraform key; its
values must match keys in `sla_domains`.

NAS servers, object inventory roles, and service accounts are also keyed maps,
so multiple instances of each can be managed. Manually added NAS shares set
`nas_server_key` to the key of the NAS server they belong to.

Credential fields in these root maps are logical names from
`vault_credential_refs`, not secret values. This applies to NAS and Cloud
Direct registrations, vSphere and Proxmox registrations, and tape targets.
The direct reusable modules continue to accept their canonical credential
fields as sensitive inputs.

To retain the prior singleton resources during state migration, use the
`standard` SLA key and `default` keys for the original inventory role, service
account, and NAS server. The root and NAS module include moved blocks for
those addresses.

## Reusable module inputs

All names used for inventory lookups are exact names, not partial or
case-insensitive matches. Where a module resolves an inventory name, that name
must match exactly one Rubrik object. Protection modules take SLA UUIDs in a
keyed `sla_ids` map so each target can use a different SLA.

### `vsphere-vm-protection`

Source: `./modules/vsphere-vm-protection`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `vm_names` | `set(string)` | Required | Exact names of vSphere VMs; each must resolve to one VM. |
| `sla_ids` | `map(string)` | `{}` | SLA UUIDs keyed by exact VM name. Every VM in `vm_names` must have an entry. |

```hcl
module "vsphere_vm_protection" {
  source = "./modules/vsphere-vm-protection"

  vm_names = ["application-01", "application-02"]
  sla_ids = {
    application-01 = "00000000-0000-0000-0000-000000000000"
    application-02 = "11111111-1111-1111-1111-111111111111"
  }
}
```

### `vsphere-container-sla-assignment`

Source: `./modules/vsphere-container-sla-assignment`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `folder_names` | `set(string)` | Required | Exact names of vSphere folders; each must resolve to one folder. Use `[]` if no folders are assigned. |
| `tag_ids` | `set(string)` | Required | Rubrik tag UUIDs. Tag names cannot be resolved by this module. Use `[]` if no tags are assigned. |
| `sla_ids` | `map(string)` | `{}` | SLA UUIDs keyed as `folder:<name>` or `tag:<UUID>`. |

```hcl
module "vsphere_container_sla_assignments" {
  source = "./modules/vsphere-container-sla-assignment"

  folder_names = ["Production"]
  tag_ids      = ["66666666-6666-6666-6666-666666666666"]
  sla_ids = {
    "folder:Production" = "00000000-0000-0000-0000-000000000000"
    "tag:66666666-6666-6666-6666-666666666666" = "11111111-1111-1111-1111-111111111111"
  }
}
```

### `postgresql-protection`

Source: `./modules/postgresql-protection`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `database_cluster_names` | `set(string)` | Required | Exact names of PostgreSQL database clusters; each must resolve to one cluster. |
| `sla_ids` | `map(string)` | `{}` | SLA UUIDs keyed by exact PostgreSQL cluster name. |

```hcl
module "postgresql_protection" {
  source = "./modules/postgresql-protection"

  database_cluster_names = ["postgres-production"]
  sla_ids = {
    postgres-production = "00000000-0000-0000-0000-000000000000"
  }
}
```

### `kubernetes-protection`

Source: `./modules/kubernetes-protection`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `cluster_names` | `set(string)` | `[]` | Exact Kubernetes cluster names; each must resolve to one cluster. |
| `protection_set_names` | `set(string)` | `[]` | Exact Kubernetes protection-set names; each must resolve to one protection set. |
| `namespaces` | `map(object)` | `{}` | Namespaces keyed by stable Terraform keys, each with exact `cluster_name` and `namespace_name` values. Namespaces are looked up within the named cluster. |
| `sla_ids` | `map(string)` | `{}` | SLA UUIDs keyed as `cluster:<name>`, `protection_set:<name>`, or `namespace:<key>`. |

```hcl
module "kubernetes_protection" {
  source = "./modules/kubernetes-protection"

  cluster_names        = ["production-k8s"]
  protection_set_names = ["production-apps"]
  namespaces = {
    production_default = {
      cluster_name   = "production-k8s"
      namespace_name = "default"
    }
  }
  sla_ids = {
    "cluster:production-k8s" = "00000000-0000-0000-0000-000000000000"
    "protection_set:production-apps" = "00000000-0000-0000-0000-000000000000"
    "namespace:production_default" = "00000000-0000-0000-0000-000000000000"
  }
}
```

Removing a configured entry unassigns its SLA; it does not delete the
Kubernetes cluster, namespace, protection set, or snapshots. A cluster
referenced only by a namespace entry is used to scope the lookup and is not
itself assigned an SLA. See the
[Kubernetes module README](./modules/kubernetes-protection/README.md).

### `proxmox-protection`

Source: `./modules/proxmox-protection`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `objects` | `map(object)` | `{}` | Objects keyed by stable Terraform keys, each with exact `name` and `object_type`. Types: `PROXMOX_ENVIRONMENT`, `PROXMOX_CLUSTER`, `PROXMOX_NODE`, or `PROXMOX_VIRTUAL_MACHINE`. The name must resolve to exactly one object of that type. |
| `sla_ids` | `map(string)` | `{}` | SLA UUIDs keyed as `object:<Terraform object key>`. |

```hcl
module "proxmox_protection" {
  source = "./modules/proxmox-protection"

  objects = {
    application_vm = {
      name        = "application-01"
      object_type = "PROXMOX_VIRTUAL_MACHINE"
    }
    cluster = {
      name        = "production"
      object_type = "PROXMOX_CLUSTER"
    }
  }
  sla_ids = {
    "object:application_vm" = "00000000-0000-0000-0000-000000000000"
    "object:cluster" = "11111111-1111-1111-1111-111111111111"
  }
}
```

Removing a configured entry unassigns its SLA without deleting the Proxmox
object or snapshots. See the
[Proxmox module README](./modules/proxmox-protection/README.md).

### `nas-share-protection`

Source: `./modules/nas-share-protection`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `share_names` | `set(string)` | `[]` | Exact names of existing/discovered shares; each must resolve to one share. |
| `nas_servers` | `map(object)`; see [NAS server inputs](#nas-server-inputs) | `{}` | NAS registrations keyed by stable Terraform names. |
| `nas_shares` | `map(object)`; see [NAS share inputs](#nas-share-inputs) | `{}` | Manually added shares; each includes its `nas_server_key`. |
| `sla_ids` | `map(string)` | `{}` | SLA UUIDs keyed as `existing:<share name>` or `configured:<share key>`. |

```hcl
module "nas_share_protection" {
  source = "./modules/nas-share-protection"

  nas_servers = {
    generic = {
      cluster_uuid = "88888888-8888-8888-8888-888888888888"
      hostname     = "nas.example.com"
      vendor_type  = "NAS_VENDOR_TYPE_GENERIC"
      generic_parameters = {
        has_nfs_support = true
        has_smb_support = false
      }
    }
  }
  nas_shares = {
    research = {
      export_point   = "/research"
      share_type     = "CREATE_NAS_SHARE_INPUT_SHARE_TYPE_NFS"
      nas_server_key = "generic"
    }
  }
  share_names = ["already-discovered-share"]
  sla_ids = {
    "configured:research" = "00000000-0000-0000-0000-000000000000"
    "existing:already-discovered-share" = "11111111-1111-1111-1111-111111111111"
  }
}
```

### `linux-fileset-protection`

Source: `./modules/linux-fileset-protection`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `cluster_uuid` | `string` | `""` | Rubrik CDM cluster UUID; required when templates or assignments are configured. |
| `fileset_templates` | `map(object)` | `{}` | Template definitions keyed by unique name. Each must include at least one `includes` path. Optional `excludes`, `exceptions`, pre/post scripts, script error handling (`abort` or `continue`), timeout in seconds, and network mount options are supported. |
| `fileset_assignments` | `map(object)` | `{}` | Assignments keyed by stable Terraform name. Each requires exact `host_name` and `template_name`; optional hardlink support and symlink resolution default to `false`. |
| `sla_ids` | `map(string)` | `{}` | SLA UUIDs keyed as `assignment:<fileset assignment key>`. Required for every configured assignment. |

```hcl
module "linux_fileset_protection" {
  source = "./modules/linux-fileset-protection"

  cluster_uuid = "88888888-8888-8888-8888-888888888888"
  sla_ids = {
    "assignment:app_server_01" = "00000000-0000-0000-0000-000000000000"
  }

  fileset_templates = {
    application = {
      includes = ["/opt/application", "/var/lib/application"]
      excludes = ["/var/lib/application/cache"]
    }
  }

  fileset_assignments = {
    app_server_01 = {
      host_name     = "app-server-01.example.com"
      template_name = "application"
    }
  }
}
```

Template/host name lookups must resolve exactly once. Template definitions
must be keyed by Rubrik template name, and assignment template names must
reference those keys. See the [module README](./modules/linux-fileset-protection/README.md)
for configuration details and lifecycle behavior.

#### NAS server inputs

Each value in `nas_servers` is a server object with the following fields:

| Field | Type | Requiredness and allowed values |
|---|---|---|
| `cluster_uuid` | `string` | Required Rubrik cluster UUID. |
| `hostname` | `string` | Required NAS server hostname/address. |
| `vendor_type` | `string` | Required. Exactly `NAS_VENDOR_TYPE_GENERIC` or `NAS_VENDOR_TYPE_ISILON` (PowerScale). |
| `generic_parameters` | Object or `null` | Required for Generic NAS; not the vendor configuration for PowerScale. Fields: `has_nfs_support` and `has_smb_support` (`bool`), optional `nfs_pseudo_fs_prefix` (`string`), optional `smb_credentials` object (`username_credential`, `password_credential`). |
| `api_credentials` | Object or `null` | Required for PowerScale. Required fields: `api_username_credential`, `api_password_credential`; optional `api_certificate_credential`, `certificate_id` strings. |
| `smb_credentials` | Object or `null` | Optional SMB credential aliases (`username_credential`, `password_credential`), where applicable. |
| `is_isilon_changelist_enabled` | `bool` or `null` | Optional PowerScale changelist setting. |

Example PowerScale server:

```hcl
nas_servers = {
  powerscale = {
    cluster_uuid = "88888888-8888-8888-8888-888888888888"
    hostname     = "powerscale.example.com"
    vendor_type  = "NAS_VENDOR_TYPE_ISILON"
    api_credentials = {
      api_username_credential = "powerscale_api_username"
      api_password_credential = "powerscale_api_password"
    }
    is_isilon_changelist_enabled = true
  }
}
```

#### NAS share inputs

`nas_shares` is a map keyed by a stable Terraform identifier. Each value has:

| Field | Type | Requiredness and allowed values |
|---|---|---|
| `export_point` | `string` | Required NAS export path/share point. |
| `share_type` | `string` | Required. Exactly `CREATE_NAS_SHARE_INPUT_SHARE_TYPE_NFS` or `CREATE_NAS_SHARE_INPUT_SHARE_TYPE_SMB`. |
| `nas_server_key` | `string` | Required key from `nas_servers` identifying the owning server. |
| `credentials` | Object or `null` | Optional; `username_credential` is required when supplied, and `password_credential` is optional. Both name keys must exist in `vault_credential_refs`. |

```hcl
nas_shares = {
  engineering = {
    export_point   = "/engineering"
    share_type     = "CREATE_NAS_SHARE_INPUT_SHARE_TYPE_NFS"
    nas_server_key = "generic"
  }
  team_smb = {
    export_point   = "team"
    share_type     = "CREATE_NAS_SHARE_INPUT_SHARE_TYPE_SMB"
    nas_server_key = "powerscale"
    credentials = {
      username_credential = "finance_share_username"
      password_credential = "finance_share_password"
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
| `FILESET_OBJECT_TYPE` | Physical host filesets, including Linux filesets |
| `K8S_OBJECT_TYPE` | CDM-native Kubernetes objects |
| `KUPR_OBJECT_TYPE` | Kubernetes objects |
| `PROXMOX_OBJECT_TYPE` | Proxmox objects |
| `NCD_OBJECT_TYPE` | NAS Cloud Direct objects |

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

### `classification-policy-analyzers`

Source: `./modules/classification-policy-analyzers`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `analyzers` | `map(object)` | `{}` | Custom analyzer definitions keyed by Terraform name. Required fields: `name`, `analyzer_type`, and `risk`. Optional fields cover dictionaries, regexes, structured-data matching, rules, exclusions, proximity, tags, and inactive status. |
| `policies` | `map(object)` | `{}` | Policy definitions keyed by Terraform name. Required field: `name`. Optional `mode` is `DISCOVERY` or `COMPLIANCE`; analyzer and target ID sets default empty. `analyzer_keys` references analyzers managed in the same module. |

Analyzer `analyzer_type` uses Rubrik `AnalyzerTypeEnum` (for example,
`REGEX`, `KEYWORD`, `EMAIL_ADDRESS`, or `US_SSN`); `risk` accepts `HIGH_RISK`,
`MEDIUM_RISK`, `LOW_RISK`, `NO_RISK`, or `UNKNOWN_RISK`; `rule_types` accepts
`STRUCTURED` and/or `UNSTRUCTURED`. See the
[module README](./modules/classification-policy-analyzers/README.md) for
examples and target assignment semantics.

```hcl
module "classification" {
  source = "./modules/classification-policy-analyzers"

  analyzers = {
    internal_reference = {
      name          = "Internal reference"
      analyzer_type = "REGEX"
      risk          = "HIGH_RISK"
      rule_types    = ["STRUCTURED", "UNSTRUCTURED"]
      regex         = "REF-[0-9]{8}"
    }
  }
  policies = {
    finance_discovery = {
      name          = "Finance discovery"
      mode          = "DISCOVERY"
      analyzer_keys = ["internal_reference"]
      object_ids    = ["00000000-0000-0000-0000-000000000000"]
    }
  }
}
```

Policy object assignments use `object_ids`, `object_root_ids`, and
`cluster_ids`. Deleting a policy or analyzer deactivates it because the
GraphQL API exposes deactivation rather than hard deletion. Assignments are
removed when their Terraform configuration is removed.

### `sensitive-data-discovery`

Source: `./modules/sensitive-data-discovery`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `enabled` | `bool` | `true` | Enables or skips reporting queries. When false, the outputs are `null`. |
| `summary_input` | `any` | `{ includeBreakdown = true }` | Rubrik `SensitiveDataSummaryInput`; optional `filter` (an `AccessFilter`) and `includeBreakdown`. |

This read-only module returns `sensitive_data_summary` and
`discovery_object_counts` (objects assigned, unassigned, or unsupported).
Configure scans by assigning objects to active `DISCOVERY` policies with
`classification-policy-analyzers`; this module does not start a scan itself.
See the [module README](./modules/sensitive-data-discovery/README.md).

### `object-inventory-role`

Source: `./modules/object-inventory-role`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `name` | `string` | Required | Name of the inventory visibility role. |
| `description` | `string` | `"Account-wide read-only access to protectable object inventory."` | Role description. |
| `vsphere_vm_names` | `set(string)` | `[]` | Exact vSphere VM names to resolve to Rubrik inventory IDs. Each name must match exactly one VM. |
| `vsphere_folder_names` | `set(string)` | `[]` | Exact vSphere folder names to resolve to Rubrik inventory IDs. Each name must match exactly one folder. |
| `postgresql_db_cluster_names` | `set(string)` | `[]` | Exact PostgreSQL cluster names to resolve to Rubrik inventory IDs. Each name must match exactly one cluster. |
| `nas_share_names` | `set(string)` | `[]` | Exact existing NAS share names to resolve to Rubrik inventory IDs. Each name must match exactly one share. |

```hcl
module "object_inventory_role" {
  source = "./modules/object-inventory-role"

  name                        = "Terraform object inventory reader"
  description                 = "Read-only visibility of protectable objects"
  vsphere_vm_names            = ["application-01"]
  vsphere_folder_names        = ["Production"]
  postgresql_db_cluster_names = ["postgres-production"]
  nas_share_names             = ["engineering-nfs"]
}
```

The module returns the outputs `vsphere_vm_ids`, `vsphere_folder_ids`,
`postgresql_db_cluster_ids`, and `nas_share_ids`, each a map from the supplied
exact name to its Rubrik inventory ID. vSphere tag IDs must be provided
directly; the current Rubrik API lookup used here does not resolve tag names.
Lookups use the calling GraphQL provider identity and do not automatically
switch to the service account created by the root configuration.

### `vsphere-server-registration`

Source: `./modules/vsphere-server-registration`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `servers` | `map(object)` | `{}` | vCenter or standalone ESXi registrations keyed by stable Terraform names. Required fields: `cluster_uuid`, `hostname`, `username`, and `password`. Optional fields: `ca_certs`, `is_standalone_host`, `should_enable_hot_add_proxy_onprem`, `conflict_resolution_authz`, `org_network_id`, and `is_compute_visibility_filter_disabled`. |

`conflict_resolution_authz` supports
`VCENTER_CONFIG_V2_CONFLICT_RESOLUTION_AUTHZ_ALLOW_AUTO_CONFLICT_RESOLUTION`
or
`VCENTER_CONFIG_V2_CONFLICT_RESOLUTION_AUTHZ_NO_CONFLICT_RESOLUTION`.
Registration credentials are stored in Terraform state.
Changes replace the registration because the API does not expose a credential
update operation; destroying an entry unregisters the server. Unregistration
can affect protection and inventory visibility. See the
[module README](./modules/vsphere-server-registration/README.md).

### `proxmox-hosts`

Source: `./modules/proxmox-hosts`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `hosts` | `map(object)` | `{}` | Existing Rubrik Proxmox environments keyed by stable Terraform names. Each object requires `environment_id` and at least one of `api_token` or `ca_certs`. |

This module updates already-registered environments; the discovered GraphQL
API has no mutation to register or unregister Proxmox environments. Removing a
Terraform entry does not deregister it or revert its credentials. Tokens are
stored in Terraform state. See the
[module README](./modules/proxmox-hosts/README.md).

### `tape-archival-targets`

Source: `./modules/tape-archival-targets`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `targets` | `map(object)` | `{}` | Tape writer targets keyed by stable Terraform names. Each requires `cluster_uuid`, `destination_folder_name`, `encryption_password`, `host_name`, `host_port`, `integral_volume_name`, `name`, `password`, and `username`. |
| `reader_targets` | `map(object)` | `{}` | Tape reader targets with the same required fields as `targets`, plus required `reader_retrieval_method` and optional `archival_data_source_ids`. Retrieval methods: `OBJECT_LIST_AND_DETAILS`, `OBJECT_LIST_ONLY`, or `SPECIFIC_OBJECT_LIST_AND_DETAILS`. |

Credentials and encryption passwords are stored in Terraform state. Rubrik
does not expose a delete mutation for tape targets, so removing an entry
preserves the target. The API update mutation only supports target name, host,
port, username, and password; it cannot change volume, folder, encryption, or
reader retrieval configuration. See the
[module README](./modules/tape-archival-targets/README.md).

### `nas-cloud-direct-systems`

Source: `./modules/nas-cloud-direct-systems`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `systems` | `map(object)` | `{}` | Cloud Direct systems keyed by stable Terraform names. Required: `cluster_id`, `host`, `system_type`, `skip_service_account_creation`, and `verify_ssl`. Optional: `username`, `password`, `region`, client certificate fields, named S3 `creds`, and vendor-specific `management_info`. |

`system_type` accepts Rubrik `CloudDirectNasVendorType` values, including
`AZURE_FILES`, `AZURE_NETAPP`, `FLASHARRAY`, `FLASHBLADE`, `FSXN`,
`GENERIC_NFS`, `GENERIC_NFS4`, `GENERIC_S3`, `GENERIC_SMB`, `ISILON`,
`NETAPP_CLUSTER_MODE`, `NUTANIX`, `QUMULO`, and `VAST_DATA`. Registration is
asynchronous and returns a job ID. Rubrik exposes no update or delete mutation;
removing a Terraform entry leaves the system registered, and changing a
registration attempts the add mutation again. Credentials are stored in state.
See the [module README](./modules/nas-cloud-direct-systems/README.md).

### `nas-cloud-direct-protection`

Source: `./modules/nas-cloud-direct-protection`

| Variable | Type | Required/default | Values and notes |
|---|---|---|---|
| `shares` | `map(object)` | `{}` | Existing Cloud Direct shares keyed by stable Terraform names, each identified by exact `name` and `system_name`. The pair must resolve to exactly one share. |
| `sla_ids` | `map(string)` | `{}` | IDs of existing SLA Domains keyed by Cloud Direct share Terraform key. |

The module assigns the SLA to existing shares and unassigns them on destroy. It
does not add shares to systems; wait for the system registration/import to
complete and the shares to appear in Rubrik first. The SLA object types must
include `NCD_OBJECT_TYPE`. See the
[module README](./modules/nas-cloud-direct-protection/README.md).

## Root outputs

The root configuration exports:

| Output | Description |
|---|---|
| `sla_domain_ids` | Map of SLA Domain keys to Rubrik IDs. |
| `object_inventory_role_ids` | Map of managed inventory-reader role keys to Rubrik IDs. |
| `vsphere_vm_ids` | Map of configured vSphere VM names to Rubrik inventory IDs. |
| `vsphere_folder_ids` | Map of configured vSphere folder names to Rubrik inventory IDs. |
| `postgresql_db_cluster_ids` | Map of configured PostgreSQL cluster names to Rubrik inventory IDs. |
| `nas_share_ids` | Map of configured existing NAS share names to Rubrik inventory IDs. |
| `linux_fileset_ids` | Map of configured Linux fileset assignment keys to Rubrik fileset IDs. |
| `kubernetes_cluster_ids` | Map of configured Kubernetes cluster names to Rubrik inventory IDs. |
| `kubernetes_protection_set_ids` | Map of configured Kubernetes protection-set names to Rubrik inventory IDs. |
| `kubernetes_namespace_ids` | Map of configured Kubernetes namespace keys to Rubrik inventory IDs. |
| `proxmox_object_ids` | Map of configured Proxmox object keys to Rubrik inventory IDs. |
| `classification_analyzer_ids` | Map of configured custom analyzer names to Rubrik IDs. |
| `classification_policy_ids` | Map of configured classification policy names to Rubrik IDs. |
| `sensitive_data_summary` | Rubrik sensitive-data summary, or `null` when reporting is disabled. |
| `data_discovery_object_counts` | Rubrik counts for assigned, unassigned, and unsupported discovery objects, or `null` when reporting is disabled. |
| `nas_server_ids` | Map of registered NAS server keys to Rubrik IDs. |
| `nas_cloud_direct_registration_job_ids` | Map of NAS Cloud Direct system keys to asynchronous registration job IDs. |
| `nas_cloud_direct_share_ids` | Map of configured NAS Cloud Direct share keys to Rubrik inventory IDs. |
| `service_account_client_id` | Map of service account keys to OAuth client IDs. |
| `service_account_client_secret` | Sensitive map of service account keys to OAuth client secrets. |
| `service_account_access_token_uri` | Map of service account keys to OAuth endpoints. |
| `vsphere_server_ids` | Map of registered vSphere server keys to Rubrik IDs. |
| `proxmox_environment_ids` | Map of configured Proxmox host keys to Rubrik environment IDs. |
| `tape_archival_target_ids` | Map of tape archival target keys to Rubrik IDs. |
| `tape_reader_target_ids` | Map of tape reader target keys to Rubrik IDs. |
