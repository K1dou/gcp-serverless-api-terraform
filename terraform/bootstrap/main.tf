resource "google_storage_bucket" "tfstate" {
  name     = var.bucket_name
  location = var.location

  # Só IAM controla o acesso (sem ACL por objeto)
  uniform_bucket_level_access = true

  # Impede que o bucket seja exposto publicamente por engano
  public_access_prevention = "enforced"

  # Recusa apagar o bucket se ele tiver objetos
  force_destroy = false

  # Guarda versões antigas do state, para poder voltar atrás
  versioning {
    enabled = true
  }

  # Mantém só as 10 versões antigas mais recentes (controla custo)
  lifecycle_rule {
    condition {
      num_newer_versions = 10
      with_state         = "ARCHIVED"
    }
    action {
      type = "Delete"
    }
  }



  labels = {
    managed_by = "terraform"
    purpose    = "tfstate"
  }

  # Trava o Terraform: um destroy ou uma troca acidental falha em vez de apagar
  lifecycle {
    prevent_destroy = true
  }
}




resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions"
  depends_on                = [google_project_service.apis]

}


resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "pipeline-github"
  description                        = "GitHub Actions identity pool provider"
  attribute_condition                = <<EOT
    assertion.repository_owner_id == "${var.github_repository_owner_id}" && 
    assertion.repository == "${var.github_repository}"
EOT


  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"        = "assertion.aud"
    "attribute.repository" = "assertion.repository"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  depends_on = [google_project_service.apis]
}



locals {
  apis = [
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com"
  ]
}

resource "google_project_service" "apis" {
  for_each = toset(local.apis)

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}