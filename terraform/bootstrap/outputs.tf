output "bucket_name" {
  description = "Nome do bucket que guarda o state do Terraform."
  value       = google_storage_bucket.tfstate.name
}