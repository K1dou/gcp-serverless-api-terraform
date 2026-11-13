output "bucket_name" {
  description = "Nome do bucket que guarda o state do Terraform."
  value       = google_storage_bucket.tfstate.name
}

output "pool_name" {
  value = google_iam_workload_identity_pool.github.name

}

output "provider_name" {
  value = google_iam_workload_identity_pool_provider.github.name
}