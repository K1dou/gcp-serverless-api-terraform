

module "network" {
  source = "../../modules/network"
  project_name = var.project_id
  subnet_network_name = "subnet-dev"
  vpc_network_name = "vpc-dev"
  region = var.region
  ip_cidr_range = "10.2.0.0/24"

  router_name="router-dev"
  nat_name="nat-dev"

depends_on = [ google_project_service.apis ]
}

module "database" {
  source = "../../modules/database"
  region = var.region
  network = module.network.network_id
  name_instance_database = "dev-instance"
  database_name = "dev_database"
  project = var.project_id
  secret_id = "password_database"

  depends_on = [ google_project_service.apis ]

}

module "service" {
  source = "../../modules/service"
  db_url_secret_id      = module.database.db_url_secret_id
  db_url_secret_version = module.database.db_url_secret_version
  project = var.project_id
  repository_id = "api-dev-repository"
  region = var.region 
  network = module.network.network_id 
  subnetwork = module.network.subnet_id

  cloud_run_name = "cloudrun-api"

  depends_on = [ google_project_service.apis ]

}