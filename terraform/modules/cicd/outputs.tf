output "provider_name" {
    value = google_iam_workload_identity_pool_provider.github.name
  
}

output "email_deploy_sa" {
  value = google_service_account.deploy_sa.email
}