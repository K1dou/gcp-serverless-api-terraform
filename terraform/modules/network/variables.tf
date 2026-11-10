variable "project_name" {
  type        = string
  description = "ID do projeto GCP onde a rede será criada (o ID, não o nome de exibição)."
}

variable "vpc_network_name" {
  type        = string
  description = "Nome da VPC."
}

variable "subnet_network_name" {
  type        = string
  description = "Nome da sub-rede."
}

variable "ip_cidr_range" {
  type        = string
  description = "Faixa de IPs da sub-rede em notação CIDR (ex.: 10.2.0.0/24). Não deve se sobrepor a outras faixas da VPC."
}

variable "region" {
  type        = string
  description = "Região GCP da sub-rede, do Cloud Router e do Cloud NAT."
}

variable "router_name" {
  type        = string
  description = "Nome do Cloud Router usado pelo Cloud NAT."
}

variable "nat_name" {
  type        = string
  description = "Nome do Cloud NAT, que dá saída para a internet sem IP público."
}
