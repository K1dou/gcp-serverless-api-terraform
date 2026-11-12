resource "google_service_account" "deploy_sa" {
  account_id   = "deploy-sa"
  display_name = "Service Account do pipeline de deploy"
}


resource "google_cloud_run_v2_service_iam_member" "iam_access_to_cloudrun_api" {
  project = var.project
  location = var.region
  name = var.cloud_run_name
  role = "roles/run.developer"
  member = "serviceAccount:${google_service_account.deploy_sa.email}"
}

resource "google_cloud_run_v2_job_iam_member" "iam_access_to_migrate_database" {
  project = var.project
  location = var.region
  name = var.migrate_job_name
  role = "roles/run.developer"
  member = "serviceAccount:${google_service_account.deploy_sa.email}"
}

resource "google_artifact_registry_repository_iam_member" "iam_access_to_repository_api_dev_repository" {
  project =var.project
  location = var.region
  repository = var.repository_name
  role = "roles/artifactregistry.writer"
  member = "serviceAccount:${google_service_account.deploy_sa.email}"
}

resource "google_service_account_iam_member" "iam_sa_as_user_sa" {
  service_account_id = var.api_sa_name
  role               = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${google_service_account.deploy_sa.email}"
}



resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "pipeline-github"
  description                        = "GitHub Actions identity pool provider"
  attribute_condition = <<EOT
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
}

resource "google_service_account_iam_member" "github_assume_deploy_sa" {
  service_account_id = google_service_account.deploy_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repository}"
}