resource "graphql_mutation" "system" {
  for_each = nonsensitive(toset(keys(var.systems)))

  mutation_variables = {
    input = jsonencode({
      clusterId                  = var.systems[each.value].cluster_id
      host                       = var.systems[each.value].host
      systemType                 = var.systems[each.value].system_type
      skipServiceAccountCreation = var.systems[each.value].skip_service_account_creation
      verifySsl                  = var.systems[each.value].verify_ssl
      certificateData            = var.systems[each.value].certificate_data
      certificateKeyPassword     = var.systems[each.value].certificate_key_password
      certificateType            = var.systems[each.value].certificate_type
      creds = [
        for credential in var.systems[each.value].creds : {
          name     = credential.name
          username = credential.username
          password = credential.password
        }
      ]
      managementInfo = var.systems[each.value].management_info == null ? null : {
        fileSystemId    = var.systems[each.value].management_info.file_system_id
        privateEndpoint = var.systems[each.value].management_info.private_endpoint
      }
      password = var.systems[each.value].password
      region   = var.systems[each.value].region
      username = var.systems[each.value].username
    })
  }

  read_query_variables  = {}
  compute_mutation_keys = { job_id = "data.addCloudDirectSystem.jobId" }
  compute_from_create   = true

  create_mutation = file("${path.module}/../../gql_files/mutation-add-cloud-direct-system.graphql")
  update_mutation = file("${path.module}/../../gql_files/mutation-add-cloud-direct-system.graphql")
  delete_mutation = file("${path.module}/../../gql_files/mutation-preserve-cloud-direct-system.graphql")
  read_query      = file("${path.module}/../../gql_files/query-empty.graphql")

  enable_remote_state_verification = false
}
