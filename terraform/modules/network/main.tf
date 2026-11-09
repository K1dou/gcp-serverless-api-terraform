resource "google_compute_network" "vpc_network" {
  project                 = var.project_name
  name                    = var.vpc_network_name
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "subnet_network" {
  name          = var.subnet_network_name
  project = var.project_name
  ip_cidr_range = var.ip_cidr_range
  region        = var.region
  network       = google_compute_network.vpc_network.id
}


