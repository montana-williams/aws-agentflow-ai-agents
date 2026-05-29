module "auth" {
  source = "./modules/auth"

  project_name = var.project_name
}

module "api_gateway" {
    source = "./modules/api_gateway"
    user_pool_id = module.auth.user_pool_id
    user_pool_client_id = module.auth.user_pool_client_id

    project_name = var.project_name
}

module "waf" {
    source = "./modules/waf"

    project_name = var.project_name
}

module "jobflow" {
    source = "./modules/jobflow"
    
     project_name = var.project_name
}

module "database" {
    source = "./modules/database"

    project_name = var.project_name
}

module "monitoring" {
    source = "./modules/monitoring"
    dlq_name = module.jobflow.dlq_name
    alert_email = var.alert_email

    project_name = var.project_name
}