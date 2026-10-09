moved {
  from = module.rubrik_sla_domain
  to   = module.rubrik_sla_domains["standard"]
}

moved {
  from = module.object_inventory_role
  to   = module.object_inventory_role["default"]
}

moved {
  from = module.automation_service_account
  to   = module.automation_service_account["default"]
}
