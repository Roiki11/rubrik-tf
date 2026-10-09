locals {
  rubrik_cluster_names = toset(compact(concat(
    [var.linux_fileset_cluster_name],
    [for server in values(var.nas_servers) : server.cluster_name],
    [for system in values(var.nas_cloud_direct_systems) : system.cluster_name],
    [for server in values(var.vsphere_servers) : server.cluster_name],
    [for target in values(var.tape_archival_targets) : target.cluster_name],
    [for target in values(var.tape_reader_targets) : target.cluster_name]
  )))
}

data "graphql_query" "rubrik_cluster_inventory" {
  for_each = length(local.rubrik_cluster_names) > 0 ? toset(["configured"]) : toset([])

  query = file("${path.module}/gql_files/cluster-connection.graphql")
  query_variables = {
    first = "100"
    after = ""
  }
  paginated = true
}

locals {
  rubrik_cluster_inventory = flatten([
    for query in values(data.graphql_query.rubrik_cluster_inventory) : flatten([
      for page in jsondecode(query.query_response).paginatedResponseData :
      page.clusterConnection.nodes
    ])
  ])

  rubrik_cluster_ids = {
    for name in local.rubrik_cluster_names :
    name => one([
      for cluster in local.rubrik_cluster_inventory : cluster.id
      if cluster.name == name
    ])
  }
}
