# 1. Reservar o bloco de IPs internos dedicado para os serviços do Google
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "psa-Ip-ranger"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.network
}

# Create a private connection
resource "google_service_networking_connection" "connection_psa" {
  network                 = var.network
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}



resource "google_sql_database_instance" "instance" {
  name             = var.name_instance_database
  region           = var.region
  database_version = "POSTGRES_14"
  settings {
    tier = "db-g1-small"

    ip_configuration {
      ipv4_enabled                                  = false        # Desliga totalmente o IP Público (Internet)
      private_network                               = var.network  # Diz para o banco escutar dentro da sua VPC
      enable_private_path_for_google_cloud_services = true
    }
  }

  deletion_protection  = true

  depends_on = [ google_service_networking_connection.connection_psa ]
}


resource "google_secret_manager_regional_secret" "regional-secret-cloud-sql-db-credentials" {
  secret_id   = "postgres-db-password"
  location    = var.region
  secret_type = "CLOUD_SQL_DB_CREDENTIALS"
}

resource "random_password" "db_password" {
  length           = 18
  special          = true
  override_special = "!#$&*()-_=+[]{}<>?" 
}


resource "google_secret_manager_regional_secret_version" "db_secret_version" {
  secret = google_secret_manager_regional_secret.regional-secret-cloud-sql-db-credentials.id
  secret_data = random_password.db_password.id
}

