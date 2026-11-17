output "email_deploy_sa" {
  description = "E-mail da deploy-sa, usado na variável DEPLOY_SA_EMAIL do GitHub Actions."
  value       = google_service_account.deploy_sa.email
}
