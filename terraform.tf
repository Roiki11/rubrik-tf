terraform {
  required_providers {
    graphql = {
      source  = "sullivtr/graphql"
      version = ">= 2.4.0"
    }
  }
}

provider "graphql" {
  url = var.rubrik_graphql_url

  headers = {
    Authorization = "Bearer ${var.rubrik_api_token}"
  }
}

module "vsphere_vm_protection" {
  source = "./modules/vsphere-vm-protection"

  vm_ids = var.vsphere_vm_ids
  sla_id = var.sla_domain_id
}
