

module "network" {
  source = "../../modules/network"
  project_name = var.project_id
  subnet_network_name = "subnet-dev"
  vpc_network_name = "vpc-dev"
  region = var.region
  ip_cidr_range = "10.2.0.0/24"

depends_on = [ google_project_service.apis ]
}