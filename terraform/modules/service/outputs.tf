output "cloud_run_url" {
  value       = google_cloud_run_v2_service.default.uri
  description = "URL pública do serviço Cloud Run."
}
