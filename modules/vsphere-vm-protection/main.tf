resource "graphql_mutation" "vsphere_vm_protection" {
  for_each = var.vm_ids

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
  read_query      = file("${path.module}/../../gql_files/vsphere-vm-by-id.graphql")

  # The provider cannot reconcile its nested input object against the VM query response.
  enable_remote_state_verification = false
}
