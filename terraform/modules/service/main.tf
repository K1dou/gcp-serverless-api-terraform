resource "google_artifact_registry_repository" "my_repo" {
  location      = var.region
  repository_id = var.repository_id
  description   = "example docker repository"
  format        = "DOCKER"

  docker_config {
    immutable_tags = true
  }
}

resource "google_service_account" "api_sa" {
  account_id   = "api-sa"
  display_name = "Service Account para a API"
}

resource "google_project_iam_member" "api_sql_client" { #nivel projeto
  project = var.project
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.api_sa.email}"
}

# ---------------------------------------------------------------------------
# Segredos do JWT: pertencem à aplicação, por isso ficam aqui no módulo service.
# ---------------------------------------------------------------------------
resource "random_password" "auth_secret" {
  length  = 32
  special = false
}

resource "random_password" "auth_refresh_secret" {
  length  = 32
  special = false
}

resource "google_secret_manager_secret" "auth_secret" {
  secret_id = "auth-secret"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "auth_secret_version" {
  secret      = google_secret_manager_secret.auth_secret.id
  secret_data = random_password.auth_secret.result
}

resource "google_secret_manager_secret" "auth_refresh_secret" {
  secret_id = "auth-refresh-secret"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "auth_refresh_secret_version" {
  secret      = google_secret_manager_secret.auth_refresh_secret.id
  secret_data = random_password.auth_refresh_secret.result
}

# ---------------------------------------------------------------------------
# Permissão da api-sa para ler cada segredo (menor privilégio: um por um)
# ---------------------------------------------------------------------------
# Permissão para ler a URL do Banco (o segredo vem do módulo database)
resource "google_secret_manager_secret_iam_member" "api_db_url_accessor" {
  secret_id = var.db_url_secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.api_sa.email}"
}

# Permissão para ler o AUTH_SECRET do JWT
resource "google_secret_manager_secret_iam_member" "auth_secret_accessor" {
  secret_id = google_secret_manager_secret.auth_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.api_sa.email}"
}

# Permissão para ler o AUTH_REFRESH_SECRET do JWT
resource "google_secret_manager_secret_iam_member" "auth_refresh_secret_accessor" {
  secret_id = google_secret_manager_secret.auth_refresh_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.api_sa.email}"
}

resource "google_cloud_run_v2_service" "default" {
  name                = var.cloud_run_name
  location            = var.region
  deletion_protection = false
  ingress             = "INGRESS_TRAFFIC_ALL"

  scaling {
    max_instance_count = 3
  }

  template {

    containers {
      image = var.container_image

      env {
        name  = "AUTH_SECRET_EXPIRES_IN"
        value = "15m"
      }

      env {
        name  = "AUTH_REFRESH_SECRET_EXPIRES_IN"
        value = "7d"
      }

      env {
        name = "DATABASE_URL"
        value_source {
          secret_key_ref {
            secret  = var.db_url_secret_id
            version = var.db_url_secret_version
          }
        }
      }

      env {
        name = "AUTH_SECRET"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.auth_secret.secret_id
            version = google_secret_manager_secret_version.auth_secret_version.version
          }
        }
      }

      env {
        name = "AUTH_REFRESH_SECRET"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.auth_refresh_secret.secret_id
            version = google_secret_manager_secret_version.auth_refresh_secret_version.version
          }
        }
      }
    }

    service_account = google_service_account.api_sa.email

    vpc_access {
      egress = "PRIVATE_RANGES_ONLY"
      network_interfaces {
        network    = var.network
        subnetwork = var.subnetwork
      }
    }

  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
    ]
  }

  # O Cloud Run confere o acesso aos segredos ao criar a revisão: as permissões
  # precisam existir antes. Nenhum atributo deste recurso as referencia, por isso
  # a ordem é declarada aqui.
  depends_on = [
    google_secret_manager_secret_iam_member.api_db_url_accessor,
    google_secret_manager_secret_iam_member.auth_secret_accessor,
    google_secret_manager_secret_iam_member.auth_refresh_secret_accessor,
  ]
}

#  Abre as portas da API para a internet (allUsers)
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  project  = google_cloud_run_v2_service.default.project
  location = google_cloud_run_v2_service.default.location
  name     = google_cloud_run_v2_service.default.name # O nome do  Cloud Run
  role     = "roles/run.invoker"
  member   = "allUsers"
}
