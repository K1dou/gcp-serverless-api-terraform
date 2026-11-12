output "network_id" {
  value       = module.network.network_id
  description = "ID da VPC do ambiente dev."
}

output "subnet_id" {
  value       = module.network.subnet_id
  description = "ID da sub-rede do ambiente dev."
}

output "api_final_url" {
  value       = module.service.cloud_run_url
  description = "URL pública da API (Cloud Run) no ambiente dev."
}

output "provider_name" {
  value = module.cicd.provider_name

}

output "email_deploy_sa" {
  value = module.cicd.email_deploy_sa
}