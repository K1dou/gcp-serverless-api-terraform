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

  private_ip_google_access = true
}



resource "google_compute_firewall" "fw_database_ingress" {
  project     = var.project_name
  name        = "fw-database-ingress"
  network     = google_compute_network.vpc_network.id
  description = "Creates firewall rule targeting tagged instances"


  allow {
    protocol  = "tcp"
    ports     = [5432]
  }

  source_ranges = [ google_compute_subnetwork.subnet_network.ip_cidr_range ]
  
}

resource "google_compute_firewall" "deny_all_external_ingress" {
  name        = "deny-external-ingress"
  network     = google_compute_network.vpc_network.id
  description = "Garante bloqueio absoluto de qualquer tentativa de entrada externa"

  direction = "INGRESS"
  priority  = 2000 # Prioridade menor que a liberação interna (executada depois)

  deny {
    protocol = "all"
  }

  # Qualquer IP vindo da internet pública
  source_ranges = ["0.0.0.0/0"]
}


resource "google_compute_router" "router" {
  name    = var.router_name
  region  = google_compute_subnetwork.subnet_network.region
  network = google_compute_network.vpc_network.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = var.nat_name
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}