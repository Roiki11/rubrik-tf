locals {
  host_names = toset([
    for assignment in values(var.fileset_assignments) : assignment.host_name
  ])

  template_create_inputs = {
    for name, template in var.fileset_templates : name => {
      clusterUuid = var.cluster_uuid
      definitions = [{
        name                      = name
        includes                  = sort(tolist(template.includes))
        excludes                  = sort(tolist(template.excludes))
        exceptions                = sort(tolist(template.exceptions))
        preBackupScript           = template.pre_backup_script
        postBackupScript          = template.post_backup_script
        backupScriptErrorHandling = template.backup_script_error_handling
        backupScriptTimeout       = template.backup_script_timeout
        operatingSystemType       = "FILESET_TEMPLATE_CREATE_OPERATING_SYSTEM_TYPE_UNIX_LIKE"
        filesetOptions = template.fileset_options == null ? null : {
          allowBackupHiddenFoldersInNetworkMounts = template.fileset_options.allow_backup_hidden_folders_in_network_mounts
          allowBackupNetworkMounts                = template.fileset_options.allow_backup_network_mounts
        }
      }]
    }
  }
}

data "graphql_query" "linux_host_by_name" {
  for_each = local.host_names

  query = file("${path.module}/../../gql_files/lookup-linux-host-by-name.graphql")
  query_variables = {
    name  = jsonencode(each.value)
    first = "100"
    after = ""
  }
  paginated = true
}

resource "graphql_mutation" "fileset_template" {
  for_each = var.fileset_templates

  mutation_variables = {
    createInput               = jsonencode(local.template_create_inputs[each.key])
    name                      = jsonencode(each.key)
    includes                  = jsonencode(sort(tolist(each.value.includes)))
    excludes                  = jsonencode(sort(tolist(each.value.excludes)))
    exceptions                = jsonencode(sort(tolist(each.value.exceptions)))
    preBackupScript           = jsonencode(each.value.pre_backup_script)
    postBackupScript          = jsonencode(each.value.post_backup_script)
    backupScriptErrorHandling = jsonencode(each.value.backup_script_error_handling)
    backupScriptTimeout       = jsonencode(each.value.backup_script_timeout)
    filesetOptions = jsonencode(each.value.fileset_options == null ? null : {
      allowBackupHiddenFoldersInNetworkMounts = each.value.fileset_options.allow_backup_hidden_folders_in_network_mounts
      allowBackupNetworkMounts                = each.value.fileset_options.allow_backup_network_mounts
    })
  }

  read_query_variables = {}

  compute_mutation_keys = {
    id = "data.bulkCreateFilesetTemplates.data[0].id"
  }
  compute_from_create = true

  create_mutation = file("${path.module}/../../gql_files/mutation-create-linux-fileset-template-managed.graphql")
  update_mutation = file("${path.module}/../../gql_files/mutation-update-linux-fileset-template-managed.graphql")
  delete_mutation = file("${path.module}/../../gql_files/mutation-preserve-linux-fileset-configuration.graphql")
  read_query      = file("${path.module}/../../gql_files/query-empty.graphql")

  lifecycle {
    precondition {
      condition     = var.cluster_uuid != "" && can(regex("^[0-9a-fA-F-]{36}$", var.cluster_uuid))
      error_message = "cluster_uuid must be a UUID when Linux fileset templates are configured."
    }
  }

  enable_remote_state_verification = false
}

resource "graphql_mutation" "linux_fileset" {
  for_each = var.fileset_assignments

  mutation_variables = {
    input = jsonencode({
      clusterUuid = var.cluster_uuid
      definitions = [{
        hostId                  = one(flatten([for page in jsondecode(data.graphql_query.linux_host_by_name[each.value.host_name].query_response).paginatedResponseData : page.physicalHosts.nodes])).id
        templateId              = try(graphql_mutation.fileset_template[each.value.template_name].computed_update_operation_variables.id, "")
        enableHardlinkSupport   = each.value.enable_hardlink_support
        enableSymlinkResolution = each.value.enable_symlink_resolution
      }]
    })
  }

  read_query_variables  = {}
  compute_mutation_keys = {}

  create_mutation = file("${path.module}/../../gql_files/mutation-create-linux-fileset-managed.graphql")
  update_mutation = file("${path.module}/../../gql_files/mutation-preserve-linux-fileset-configuration.graphql")
  delete_mutation = file("${path.module}/../../gql_files/mutation-preserve-linux-fileset-configuration.graphql")
  read_query      = file("${path.module}/../../gql_files/query-empty.graphql")

  lifecycle {
    precondition {
      condition     = contains(keys(var.fileset_templates), each.value.template_name)
      error_message = "Each fileset assignment must reference a key in fileset_templates."
    }
    precondition {
      condition     = var.cluster_uuid != "" && can(regex("^[0-9a-fA-F-]{36}$", var.cluster_uuid))
      error_message = "cluster_uuid must be a UUID when fileset assignments are configured."
    }
  }

  enable_remote_state_verification = false
}

data "graphql_query" "linux_filesets_by_host" {
  for_each = local.host_names

  query = file("${path.module}/../../gql_files/query-linux-filesets-for-host.graphql")
  query_variables = {
    fid   = jsonencode(one(flatten([for page in jsondecode(data.graphql_query.linux_host_by_name[each.value].query_response).paginatedResponseData : page.physicalHosts.nodes])).id)
    first = "1000"
  }

  depends_on = [graphql_mutation.linux_fileset]
}

locals {
  fileset_ids = {
    for key, assignment in var.fileset_assignments :
    key => one([
      for fileset in jsondecode(data.graphql_query.linux_filesets_by_host[assignment.host_name].query_response).data.physicalHost.descendantConnection.nodes :
      fileset.id if fileset.name == assignment.template_name
    ])
  }
}

resource "graphql_mutation" "linux_fileset_protection" {
  for_each = local.fileset_ids

  mutation_variables = {
    input = jsonencode({
      objectIds           = [each.value]
      slaDomainAssignType = "protectWithSlaId"
      slaOptionalId       = var.sla_id
    })
  }

  read_query_variables = {
    fid = jsonencode(each.value)
  }

  delete_mutation_variables = {
    input = jsonencode({
      objectIds           = [each.value]
      slaDomainAssignType = "doNotProtect"
    })
  }

  compute_mutation_keys = {}

  create_mutation = file("${path.module}/../../gql_files/assign-sla.graphql")
  update_mutation = file("${path.module}/../../gql_files/assign-sla.graphql")
  delete_mutation = file("${path.module}/../../gql_files/assign-sla.graphql")
  read_query      = file("${path.module}/../../gql_files/query-linux-fileset.graphql")

  lifecycle {
    precondition {
      condition     = can(regex("^[0-9a-fA-F-]{36}$", var.sla_id))
      error_message = "A valid SLA Domain UUID is required when fileset assignments are configured."
    }
  }

  enable_remote_state_verification = false
}
