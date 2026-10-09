module "nas_cloud_direct_systems" {
  source = "./modules/nas-cloud-direct-systems"

  systems = local.resolved_nas_cloud_direct_systems
}

module "nas_share_protection" {
  source = "./modules/nas-share-protection"

  nas_servers = local.resolved_nas_servers
  nas_shares  = local.resolved_nas_shares
  share_names = toset(keys(var.nas_existing_shares))
  sla_ids     = local.nas_sla_ids
}

module "vsphere_server_registration" {
  source = "./modules/vsphere-server-registration"

  servers = local.resolved_vsphere_servers
}

module "proxmox_hosts" {
  source = "./modules/proxmox-hosts"

  hosts = local.resolved_proxmox_hosts
}

module "tape_archival_targets" {
  source = "./modules/tape-archival-targets"

  targets        = local.resolved_tape_archival_targets
  reader_targets = local.resolved_tape_reader_targets
}
