locals {
  nas_system_mutation_variables = var.nas_server == null ? {} : {
    clusterUuid   = jsonencode(var.nas_server.cluster_uuid)
    hostname      = jsonencode(var.nas_server.hostname)
    nasVendorType = jsonencode(var.nas_server.vendor_type)
    genericNasSystemParameters = jsonencode(var.nas_server.generic_parameters == null ? null : {
      hasNfsSupport = var.nas_server.generic_parameters.has_nfs_support
      hasSmbSupport = var.nas_server.generic_parameters.has_smb_support
      nfsPseudoFsPrefix = try(
        var.nas_server.generic_parameters.nfs_pseudo_fs_prefix,
        null
      )
      smbCredentials = try(var.nas_server.generic_parameters.smb_credentials, null) == null ? null : {
        username = var.nas_server.generic_parameters.smb_credentials.username
        password = var.nas_server.generic_parameters.smb_credentials.password
      }
    })
    nasApiCredentials = jsonencode(var.nas_server.api_credentials == null ? null : {
      apiUsername    = var.nas_server.api_credentials.api_username
      apiPassword    = var.nas_server.api_credentials.api_password
      apiCertificate = try(var.nas_server.api_credentials.api_certificate, null)
      certificateId  = try(var.nas_server.api_credentials.certificate_id, null)
    })
    smbCredentials = jsonencode(var.nas_server.smb_credentials == null ? null : {
      username = var.nas_server.smb_credentials.username
      password = var.nas_server.smb_credentials.password
    })
    isIsilonChangelistEnabled = jsonencode(try(var.nas_server.is_isilon_changelist_enabled, null))
  }

  nas_server_id = try(
    graphql_mutation.nas_system["server"].computed_update_operation_variables.fid,
    null
  )

  configured_shares = {
    for key, share in var.nas_shares : key => {
      id = graphql_mutation.nas_share_configuration[key].computed_update_operation_variables.fid
    }
  }

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
        id = share.id
      }
    },
    {
      for key, share in local.configured_shares : "configured:${key}" => share
    }
  )
}

resource "graphql_mutation" "nas_system" {
  for_each = nonsensitive(var.nas_server == null) ? {} : { server = "server" }

  mutation_variables = local.nas_system_mutation_variables

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

resource "graphql_mutation" "nas_share_configuration" {
  for_each = nonsensitive(toset(keys(var.nas_shares)))

  mutation_variables = {
    nasSourceId = jsonencode(local.nas_server_id)
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
      condition     = local.nas_server_id != null
      error_message = "nas_server must be configured before manually adding NAS shares."
    }
  }

  enable_remote_state_verification = false
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

resource "graphql_mutation" "nas_share_protection" {
  for_each = nonsensitive(local.shares_to_protect)

  mutation_variables = {
    input = jsonencode({
      objectIds           = [each.value.id]
      slaDomainAssignType = "protectWithSlaId"
      slaOptionalId       = var.sla_id
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

  enable_remote_state_verification = false
}
