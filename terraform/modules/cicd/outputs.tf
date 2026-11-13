

output "email_deploy_sa" {
  value = google_service_account.deploy_sa.email
}