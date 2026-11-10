output "network_id" {
  value       = google_compute_network.vpc_network.id
  description = "ID da VPC, usado pelos módulos database e service."
}

output "subnet_id" {
  value       = google_compute_subnetwork.subnet_network.id
  description = "ID da sub-rede, usado pelo Cloud Run para entrar na VPC."
}
