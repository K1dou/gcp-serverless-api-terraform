output "network_id" {
  value = module.network.network_id
}
output "subnet_id" {
  value = module.network.subnet_id
}

output "api_final_url" {
  value = module.service.cloud_run_url
}