resource "graphql_mutation" "host" {
  for_each = nonsensitive(toset(keys(var.hosts)))

  mutation_variables = {
    input = jsonencode({
      id = var.hosts[each.value].environment_id
      updateProperties = {
        apiToken = var.hosts[each.value].api_token
        caCerts  = var.hosts[each.value].ca_certs
      }
    })
  }

  read_query_variables = {
    fids = jsonencode([var.hosts[each.value].environment_id])
  }

  compute_mutation_keys = {}

  create_mutation = file("${path.module}/../../gql_files/mutation-update-proxmox-host-managed.graphql")
  update_mutation = file("${path.module}/../../gql_files/mutation-update-proxmox-host-managed.graphql")
  delete_mutation = file("${path.module}/../../gql_files/mutation-update-proxmox-host-managed.graphql")
  read_query      = file("${path.module}/../../gql_files/query-hierarchy-objects.graphql")

  lifecycle {
    precondition {
      condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.hosts[each.value].environment_id))
      error_message = "Each Proxmox environment_id must be a UUID."
    }
  }

  enable_remote_state_verification = false
}
