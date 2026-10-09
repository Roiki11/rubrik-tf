# Rubrik Linux Fileset Protection

Creates and updates Linux fileset templates, applies them to existing Linux
hosts, and assigns an existing SLA Domain to the resulting filesets. The
calling configuration must configure the `sullivtr/graphql` provider.

```hcl
module "linux_fileset_protection" {
  source = "./modules/linux-fileset-protection"

  cluster_uuid = "00000000-0000-0000-0000-000000000000"
  sla_ids = {
    "assignment:app_server_01" = "11111111-1111-1111-1111-111111111111"
    "assignment:app_server_02" = "22222222-2222-2222-2222-222222222222"
  }

  fileset_templates = {
    application = {
      includes = ["/opt/application", "/var/lib/application"]
      excludes = ["/var/lib/application/cache"]
      exceptions = ["/var/lib/application/cache/keep"]
      fileset_options = {
        allow_backup_network_mounts = false
      }
    }
  }

  fileset_assignments = {
    app_server_01 = {
      host_name                 = "app-server-01.example.com"
      template_name             = "application"
      enable_hardlink_support   = true
      enable_symlink_resolution = false
    }
    app_server_02 = {
      host_name     = "app-server-02.example.com"
      template_name = "application"
    }
  }
}
```

## Inputs

- `cluster_uuid`: UUID of the Rubrik CDM cluster where templates/filesets are
  created.
- `sla_ids`: SLA Domain UUIDs keyed as `assignment:<fileset assignment key>`.
- `fileset_templates`: map keyed by unique Rubrik template name. `includes`
  must contain at least one path; `excludes` and `exceptions` are optional.
  Optional pre/post backup scripts, script error handling (`abort` or
  `continue`), timeout in seconds, and network mount options can be configured.
- `fileset_assignments`: map keyed by stable Terraform identifiers. Each
  entry names an existing Linux host and a key from `fileset_templates`.
  Hardlink support and symlink resolution default to `false`.

Host and template lookups use exact names. Every host and template lookup must
resolve to exactly one Rubrik object. Paths and scripts are passed through to
Rubrik; the Rubrik API version and host agent determine which options are
available.

## Lifecycle

- Templates are created/updated through Rubrik's bulk fileset-template
  mutations. Removing a template declaration from Terraform preserves the
  Rubrik template; it is not deleted.
- Applying a template creates a fileset on each configured host. The module
  discovers the resulting fileset ID from the host's Linux fileset descendants,
  then assigns the configured SLA.
- Template definitions are updated in Rubrik when their inputs change.
  Applying an already-created template to a host is create-only; changing an
  assignment's host, template, hardlink, or symlink settings does not modify the
  existing fileset in place. To replace it, create a new template name and
  assignment key, verify the new fileset, then remove the old assignment to
  unprotect its fileset.
- Removing an assignment unprotects its fileset (`doNotProtect`) but preserves
  the fileset and its snapshots. Removing template or assignment configuration
  therefore does not delete data or Rubrik fileset objects.
- Re-adding a removed template/assignment may encounter the existing Rubrik
  object. Review the existing state in Rubrik before reapplying.
- The Rubrik SLA Domain must include the `FILESET_OBJECT_TYPE` object type.

Fileset creation is asynchronous on some Rubrik versions. The query that
discovers the newly created fileset runs after the create mutation; live
behavior should be verified against the target cluster before production use.
The GraphQL provider cannot reconcile nested SLA-assignment input against
fileset query state, so remote state verification for protection is disabled.
