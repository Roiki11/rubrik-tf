resource "graphql_mutation" "server" {
  for_each = nonsensitive(toset(keys(var.servers)))

  mutation_variables = {
    input = jsonencode({
      clusterUuid = var.servers[each.value].cluster_uuid
      vcenterDetail = {
        hostname                          = var.servers[each.value].hostname
        username                          = var.servers[each.value].username
        password                          = var.servers[each.value].password
        caCerts                           = var.servers[each.value].ca_certs
        isStandaloneHost                  = var.servers[each.value].is_standalone_host
        shouldEnableHotAddProxyForOnPrem  = var.servers[each.value].should_enable_hot_add_proxy_onprem
        conflictResolutionAuthz           = var.servers[each.value].conflict_resolution_authz
        orgNetworkId                      = var.servers[each.value].org_network_id
        isComputeVisibilityFilterDisabled = var.servers[each.value].is_compute_visibility_filter_disabled
      }
    })
  }

  read_query_variables = {
    name  = jsonencode(var.servers[each.value].hostname)
    first = "100"
  }

  compute_mutation_keys = {
    id = "data.createVsphereVcenter.id"
  }
  compute_from_create = true
  force_replace       = true

  create_mutation = file("${path.module}/../../gql_files/mutation-register-vsphere-server-managed.graphql")
  update_mutation = file("${path.module}/../../gql_files/mutation-register-vsphere-server-managed.graphql")
  delete_mutation = file("${path.module}/../../gql_files/mutation-unregister-vsphere-server-managed.graphql")
  read_query      = file("${path.module}/../../gql_files/lookup-vsphere-server-by-name.graphql")

  lifecycle {
    precondition {
      condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.servers[each.value].cluster_uuid))
      error_message = "Each vSphere server cluster_uuid must be a UUID."
    }
  }

  enable_remote_state_verification = false
}
