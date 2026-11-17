output "cloud_run_url" {
  value       = google_cloud_run_v2_service.default.uri
  description = "URL pública do serviço Cloud Run."
}
output "cloud_run_name" {
  value       = google_cloud_run_v2_service.default.name
  description = "Nome do serviço Cloud Run."
}

output "migrate_job_name" {
  value       = google_cloud_run_v2_job.default.name
  description = "Nome do Job de migrations."
}

output "api_sa_name" {
  value       = google_service_account.api_sa.name
  description = "ID completo da api-sa, usado para conceder serviceAccountUser."
}

output "repository_name" {
  value = google_artifact_registry_repository.my_repo.repository_id

}