resource "graphql_mutation" "nas_system" {
  for_each = nonsensitive(toset(keys(var.nas_servers)))

  mutation_variables = {
    clusterUuid   = jsonencode(var.nas_servers[each.value].cluster_uuid)
    hostname      = jsonencode(var.nas_servers[each.value].hostname)
    nasVendorType = jsonencode(var.nas_servers[each.value].vendor_type)
    genericNasSystemParameters = jsonencode(var.nas_servers[each.value].generic_parameters == null ? null : {
      hasNfsSupport = var.nas_servers[each.value].generic_parameters.has_nfs_support
      hasSmbSupport = var.nas_servers[each.value].generic_parameters.has_smb_support
      nfsPseudoFsPrefix = try(
        var.nas_servers[each.value].generic_parameters.nfs_pseudo_fs_prefix,
        null
      )
      smbCredentials = try(var.nas_servers[each.value].generic_parameters.smb_credentials, null) == null ? null : {
        username = var.nas_servers[each.value].generic_parameters.smb_credentials.username
        password = var.nas_servers[each.value].generic_parameters.smb_credentials.password
      }
    })
    nasApiCredentials = jsonencode(var.nas_servers[each.value].api_credentials == null ? null : {
      apiUsername    = var.nas_servers[each.value].api_credentials.api_username
      apiPassword    = var.nas_servers[each.value].api_credentials.api_password
      apiCertificate = try(var.nas_servers[each.value].api_credentials.api_certificate, null)
      certificateId  = try(var.nas_servers[each.value].api_credentials.certificate_id, null)
    })
    smbCredentials = jsonencode(var.nas_servers[each.value].smb_credentials == null ? null : {
      username = var.nas_servers[each.value].smb_credentials.username
      password = var.nas_servers[each.value].smb_credentials.password
    })
    isIsilonChangelistEnabled = jsonencode(try(var.nas_servers[each.value].is_isilon_changelist_enabled, null))
  }

  compute_mutation_keys = {
    fid = "data.registerNasSystem.nasSystemSummary.id"
  }
  compute_from_create = true

  create_mutation = file("${path.module}/../../gql_files/mutation-register-nas-system-managed.graphql")
  update_mutation = file("${path.module}/../../gql_files/mutation-update-nas-system-managed.graphql")
  delete_mutation = file("${path.module}/../../gql_files/mutation-preserve-nas-objects.graphql")
  read_query      = file("${path.module}/../../gql_files/query-nas-system.graphql")

  enable_remote_state_verification = false
}

locals {
  nas_server_ids = {
    for key, mutation in graphql_mutation.nas_system :
    key => mutation.computed_update_operation_variables.fid
  }
}

resource "graphql_mutation" "nas_share_configuration" {
  for_each = nonsensitive(toset(keys(var.nas_shares)))

  mutation_variables = {
    nasSourceId = jsonencode(try(local.nas_server_ids[var.nas_shares[each.value].nas_server_key], ""))
    exportPoint = jsonencode(var.nas_shares[each.value].export_point)
    shareType   = jsonencode(var.nas_shares[each.value].share_type)
    credentials = jsonencode(var.nas_shares[each.value].credentials == null ? null : {
      username = var.nas_shares[each.value].credentials.username
      password = try(var.nas_shares[each.value].credentials.password, null)
    })
  }

  read_query_variables = {}

  compute_mutation_keys = {
    fid = "data.bulkAddNasShares.nasShareDetails[0].id"
  }
  compute_from_create = true

  create_mutation = file("${path.module}/../../gql_files/mutation-add-nas-share-managed.graphql")
  update_mutation = file("${path.module}/../../gql_files/mutation-update-nas-share-managed.graphql")
  delete_mutation = file("${path.module}/../../gql_files/mutation-preserve-nas-objects.graphql")
  read_query      = file("${path.module}/../../gql_files/query-nas-share.graphql")

  lifecycle {
    precondition {
      condition     = contains(keys(var.nas_servers), var.nas_shares[each.value].nas_server_key)
      error_message = "Each manually added NAS share must reference a key in nas_servers."
    }
  }

  enable_remote_state_verification = false
}

locals {
  configured_shares = {
    for key, share in var.nas_shares : key => {
      id = graphql_mutation.nas_share_configuration[key].computed_update_operation_variables.fid
    }
  }
}

data "graphql_query" "share_by_name" {
  for_each = var.share_names

  query = file("${path.module}/../../gql_files/lookup-nas-share-by-name.graphql")
  query_variables = {
    name  = jsonencode(each.value)
    first = "100"
    after = ""
  }
  paginated = true
}

locals {
  existing_shares = {
    for name, query in data.graphql_query.share_by_name :
    "existing:${name}" => one(flatten([
      for page in jsondecode(query.query_response).paginatedResponseData :
      page.nasShares.nodes
    ]))
    if !contains(
      [for share in values(local.configured_shares) : share.id],
      one(flatten([
        for page in jsondecode(query.query_response).paginatedResponseData :
        page.nasShares.nodes
      ])).id
    )
  }

  shares_to_protect = merge(
    {
      for key, share in local.existing_shares : key => {
        id     = share.id
        sla_id = lookup(var.sla_ids, key, "")
      }
    },
    {
      for key, share in local.configured_shares : "configured:${key}" => {
        id     = share.id
        sla_id = lookup(var.sla_ids, "configured:${key}", "")
      }
    }
  )
}

resource "graphql_mutation" "nas_share_protection" {
  for_each = nonsensitive(local.shares_to_protect)

  mutation_variables = {
    input = jsonencode({
      objectIds           = [each.value.id]
      slaDomainAssignType = "protectWithSlaId"
      slaOptionalId       = each.value.sla_id
    })
  }

  read_query_variables = {
    fid = jsonencode(each.value.id)
  }

  delete_mutation_variables = {
    input = jsonencode({
      objectIds           = [each.value.id]
      slaDomainAssignType = "doNotProtect"
    })
  }

  compute_mutation_keys = {}

  create_mutation = file("${path.module}/../../gql_files/assign-sla.graphql")
  update_mutation = file("${path.module}/../../gql_files/assign-sla.graphql")
  delete_mutation = file("${path.module}/../../gql_files/assign-sla.graphql")
  read_query      = file("${path.module}/../../gql_files/query-nas-share.graphql")

  lifecycle {
    precondition {
      condition = can(regex(
        "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$",
        each.value.sla_id
      ))
      error_message = "Each NAS share must be assigned a valid SLA Domain UUID in sla_ids."
    }
  }

  enable_remote_state_verification = false
}
