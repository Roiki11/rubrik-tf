output "vm_protection_state" {
  description = "The VM details returned by Rubrik after each protection assignment."
  value = {
    for vm_id, protection in graphql_mutation.vsphere_vm_protection :
    vm_id => jsondecode(protection.query_response).data.vSphereVmNew
  }
}
