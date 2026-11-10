resource "google_artifact_registry_repository" "my-repo" {
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
  display_name= "Service Account para a API"
}



resource "google_project_iam_member" "api_sql_client" { #nivel projeto
  project = var.project
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.api_sa.email}"
}

resource "google_secret_manager_secret_iam_member" "api_secret_accessor" { #acesso direto 
  secret_id   = var.secret_id # ID do segredo que virá do output do módulo de database!
  role        = "roles/secretmanager.secretAccessor" # Permissão estrita para ler o dado do cofre
  member      = "serviceAccount:${google_service_account.api_sa.email}"
}


resource "google_cloud_run_v2_service" "default" {
  name     = var.cloud_run_name
  location = var.region
  deletion_protection = false
  ingress = "INGRESS_TRAFFIC_ALL"

  scaling {
    max_instance_count = 3
  }


  template {

    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      
    }

    service_account = google_service_account.api_sa.email


    vpc_access {
      egress = "PRIVATE_RANGES_ONLY"
      network_interfaces {
        network = var.network
        subnetwork = var.subnetwork
      }
    }

    

  }
  lifecycle {
  ignore_changes = [
    template[0].containers[0].image,
  ]
}
}

#  Abre as portas da API para a internet (allUsers)
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  project = google_cloud_run_v2_service.default.project 
  location = google_cloud_run_v2_service.default.location
  name = google_cloud_run_v2_service.default.name # O nome do  Cloud Run
  role     = "roles/run.invoker" 
  member   = "allUsers"  
}