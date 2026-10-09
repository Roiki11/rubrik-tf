terraform {
  required_providers {
    graphql = {
      source  = "sullivtr/graphql"
      version = ">= 2.4.0"
    }
  }
}

data "graphql_query" "cluster_by_name" {
  for_each = local.cluster_names

  query = file("${path.module}/../../gql_files/lookup-k8s-cluster-by-name.graphql")
  query_variables = {
    name  = jsonencode(each.value)
    first = "100"
    after = ""
  }
  paginated = true
}

data "graphql_query" "protection_set_by_name" {
  for_each = var.protection_set_names

  query = file("${path.module}/../../gql_files/lookup-kubernetes-protection-set-by-name.graphql")
  query_variables = {
    name  = jsonencode(each.value)
    first = "100"
    after = ""
  }
  paginated = true
}

locals {
  cluster_names = setunion(
    var.cluster_names,
    toset([for namespace in values(var.namespaces) : namespace.cluster_name])
  )

  clusters_by_name = {
    for name, query in data.graphql_query.cluster_by_name :
    name => one(flatten([
      for page in jsondecode(query.query_response).paginatedResponseData :
      page.k8sClusters.nodes
    ]))
  }

  clusters_for_protection = {
    for name, cluster in local.clusters_by_name :
    name => cluster
    if contains(var.cluster_names, name)
  }

  protection_sets_by_name = {
    for name, query in data.graphql_query.protection_set_by_name :
    name => one(flatten([
      for page in jsondecode(query.query_response).paginatedResponseData :
      page.kubernetesProtectionSets.nodes
    ]))
  }

  namespace_cluster_ids = {
    for key, namespace in var.namespaces :
    key => local.clusters_by_name[namespace.cluster_name].id
  }
}

data "graphql_query" "namespace_by_name" {
  for_each = var.namespaces

  query = file("${path.module}/../../gql_files/lookup-k8s-namespace-by-name.graphql")
  query_variables = {
    name      = jsonencode(each.value.namespace_name)
    clusterId = jsonencode(local.namespace_cluster_ids[each.key])
    first     = "100"
    after     = ""
  }
  paginated = true
}

locals {
  namespaces_by_key = {
    for key, query in data.graphql_query.namespace_by_name :
    key => one(flatten([
      for page in jsondecode(query.query_response).paginatedResponseData :
      page.k8sNamespaces.nodes
    ]))
  }
}

resource "graphql_mutation" "cluster_protection" {
  for_each = local.clusters_for_protection

  mutation_variables = {
    input = jsonencode({
      objectIds           = [each.value.id]
      slaDomainAssignType = "protectWithSlaId"
      slaOptionalId       = lookup(var.sla_ids, "cluster:${each.key}", "")
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
  read_query      = file("${path.module}/../../gql_files/query-k8s-cluster.graphql")

  lifecycle {
    precondition {
      condition = can(regex(
        "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$",
        lookup(var.sla_ids, "cluster:${each.key}", "")
      ))
      error_message = "Each Kubernetes cluster must be assigned a valid SLA Domain UUID in sla_ids."
    }
  }

  enable_remote_state_verification = false
}

resource "graphql_mutation" "protection_set_protection" {
  for_each = local.protection_sets_by_name

  mutation_variables = {
    input = jsonencode({
      objectIds           = [each.value.id]
      slaDomainAssignType = "protectWithSlaId"
      slaOptionalId       = lookup(var.sla_ids, "protection_set:${each.key}", "")
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
  read_query      = file("${path.module}/../../gql_files/query-kubernetes-protection-set.graphql")

  lifecycle {
    precondition {
      condition = can(regex(
        "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$",
        lookup(var.sla_ids, "protection_set:${each.key}", "")
      ))
      error_message = "Each Kubernetes protection set must be assigned a valid SLA Domain UUID in sla_ids."
    }
  }

  enable_remote_state_verification = false
}

resource "graphql_mutation" "namespace_protection" {
  for_each = local.namespaces_by_key

  mutation_variables = {
    input = jsonencode({
      objectIds           = [each.value.id]
      slaDomainAssignType = "protectWithSlaId"
      slaOptionalId       = lookup(var.sla_ids, "namespace:${each.key}", "")
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
  read_query      = file("${path.module}/../../gql_files/query-k8s-namespace.graphql")

  lifecycle {
    precondition {
      condition = can(regex(
        "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$",
        lookup(var.sla_ids, "namespace:${each.key}", "")
      ))
      error_message = "Each Kubernetes namespace must be assigned a valid SLA Domain UUID in sla_ids."
    }
  }

  enable_remote_state_verification = false
}
