data "graphql_query" "vm_by_name" {
  for_each = var.vm_names

  query = file("${path.module}/../../gql_files/lookup-vsphere-vm-by-name.graphql")
  query_variables = {
    name  = jsonencode(each.value)
    first = "100"
    after = ""
  }
  paginated = true
}

locals {
  vms_by_name = {
    for name, query in data.graphql_query.vm_by_name :
    name => one(flatten([
      for page in jsondecode(query.query_response).paginatedResponseData :
      page.vSphereVmNewConnection.nodes
    ]))
  }
}

resource "graphql_mutation" "vsphere_vm_protection" {
  for_each = local.vms_by_name

  mutation_variables = {
    input = jsonencode({
      objectIds           = [each.value.id]
      slaDomainAssignType = "protectWithSlaId"
      slaOptionalId       = lookup(var.sla_ids, each.key, "")
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
  read_query      = file("${path.module}/../../gql_files/vsphere-vm-by-id.graphql")

  lifecycle {
    precondition {
      condition = can(regex(
        "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$",
        lookup(var.sla_ids, each.key, "")
      ))
      error_message = "Each vSphere VM must be assigned a valid SLA Domain UUID in sla_ids."
    }
  }

  # The provider cannot reconcile its nested input object against the VM query response.
  enable_remote_state_verification = false
}
