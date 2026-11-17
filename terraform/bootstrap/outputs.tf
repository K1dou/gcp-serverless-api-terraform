output "bucket_name" {
  description = "Nome do bucket que guarda o state do Terraform."
  value       = google_storage_bucket.tfstate.name
}

output "pool_name" {
  description = "Nome completo do Workload Identity Pool, lido pelo dev via remote state."
  value       = google_iam_workload_identity_pool.github.name
}

output "provider_name" {
  description = "Nome completo do provider do WIF, usado na variável WIF_PROVIDER do GitHub Actions."
  value       = google_iam_workload_identity_pool_provider.github.name
}