data "vault_kv_secret_v2" "credential" {
  for_each = var.vault_credential_refs

  mount = each.value.mount
  name  = each.value.path
}

locals {
  vault_credentials = {
    for name, ref in var.vault_credential_refs :
    name => sensitive(tostring(data.vault_kv_secret_v2.credential[name].data[ref.key]))
  }

  resolved_nas_servers = {
    for key, server in var.nas_servers : key => {
      cluster_uuid = local.rubrik_cluster_ids[server.cluster_name]
      hostname     = server.hostname
      vendor_type  = server.vendor_type
      generic_parameters = server.generic_parameters == null ? null : {
        has_nfs_support      = server.generic_parameters.has_nfs_support
        has_smb_support      = server.generic_parameters.has_smb_support
        nfs_pseudo_fs_prefix = server.generic_parameters.nfs_pseudo_fs_prefix
        smb_credentials = try(server.generic_parameters.smb_credentials, null) == null ? null : {
          username = local.vault_credentials[server.generic_parameters.smb_credentials.username_credential]
          password = local.vault_credentials[server.generic_parameters.smb_credentials.password_credential]
        }
      }
      api_credentials = server.api_credentials == null ? null : {
        api_username = local.vault_credentials[server.api_credentials.api_username_credential]
        api_password = local.vault_credentials[server.api_credentials.api_password_credential]
        api_certificate = try(server.api_credentials.api_certificate_credential, null) == null ? null : local.vault_credentials[
          server.api_credentials.api_certificate_credential
        ]
        certificate_id = try(server.api_credentials.certificate_id, null)
      }
      smb_credentials = try(server.smb_credentials, null) == null ? null : {
        username = local.vault_credentials[server.smb_credentials.username_credential]
        password = local.vault_credentials[server.smb_credentials.password_credential]
      }
      is_isilon_changelist_enabled = server.is_isilon_changelist_enabled
    }
  }

  resolved_nas_shares = {
    for key, share in var.nas_shares : key => merge(share, {
      credentials = try(share.credentials, null) == null ? null : {
        username = local.vault_credentials[share.credentials.username_credential]
        password = try(share.credentials.password_credential, null) == null ? null : local.vault_credentials[
          share.credentials.password_credential
        ]
      }
    })
  }

  resolved_nas_cloud_direct_systems = {
    for key, system in var.nas_cloud_direct_systems : key => merge({
      for name, value in system : name => value
      if name != "cluster_name"
      }, {
      cluster_id = local.rubrik_cluster_ids[system.cluster_name]
      certificate_data = try(system.certificate_data_credential, null) == null ? null : local.vault_credentials[
        system.certificate_data_credential
      ]
      certificate_key_password = try(system.certificate_key_password_credential, null) == null ? null : local.vault_credentials[
        system.certificate_key_password_credential
      ]
      creds = [
        for credential in system.creds : {
          name     = credential.name
          username = local.vault_credentials[credential.username_credential]
          password = local.vault_credentials[credential.password_credential]
        }
      ]
      password = try(system.password_credential, null) == null ? null : local.vault_credentials[
        system.password_credential
      ]
      username = try(system.username_credential, null) == null ? null : local.vault_credentials[
        system.username_credential
      ]
    })
  }

  resolved_vsphere_servers = {
    for key, server in var.vsphere_servers : key => merge({
      for name, value in server : name => value
      if name != "cluster_name"
      }, {
      cluster_uuid = local.rubrik_cluster_ids[server.cluster_name]
      username     = local.vault_credentials[server.username_credential]
      password     = local.vault_credentials[server.password_credential]
      ca_certs = try(server.ca_certs_credential, null) == null ? null : local.vault_credentials[
        server.ca_certs_credential
      ]
    })
  }

  resolved_proxmox_hosts = {
    for key, host in var.proxmox_hosts : key => {
      environment_id = host.environment_id
      api_token = try(host.api_token_credential, null) == null ? null : local.vault_credentials[
        host.api_token_credential
      ]
      ca_certs = try(host.ca_certs_credential, null) == null ? null : local.vault_credentials[
        host.ca_certs_credential
      ]
    }
  }

  resolved_tape_archival_targets = {
    for key, target in var.tape_archival_targets : key => merge({
      for name, value in target : name => value
      if name != "cluster_name"
      }, {
      cluster_uuid        = local.rubrik_cluster_ids[target.cluster_name]
      encryption_password = local.vault_credentials[target.encryption_password_credential]
      password            = local.vault_credentials[target.password_credential]
      username            = local.vault_credentials[target.username_credential]
    })
  }

  resolved_tape_reader_targets = {
    for key, target in var.tape_reader_targets : key => merge({
      for name, value in target : name => value
      if name != "cluster_name"
      }, {
      cluster_uuid        = local.rubrik_cluster_ids[target.cluster_name]
      encryption_password = local.vault_credentials[target.encryption_password_credential]
      password            = local.vault_credentials[target.password_credential]
      username            = local.vault_credentials[target.username_credential]
    })
  }
}
