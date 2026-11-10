variable "region" {
  type        = string
  description = "Região GCP do Cloud Run e do Artifact Registry."
}

variable "repository_id" {
  type        = string
  description = "ID do repositório de imagens de container no Artifact Registry."
}

variable "secret_id" {
  type        = string
  description = "ID do segredo no Secret Manager com a senha do banco (output secret_id do módulo database). A api-sa recebe permissão de leitura nele."
}

variable "project" {
  type        = string
  description = "ID do projeto GCP onde os recursos do serviço serão criados."
}

variable "network" {
  type        = string
  description = "ID da VPC à qual o Cloud Run se conecta (output network_id do módulo network)."
}

variable "subnetwork" {
  type        = string
  description = "ID da sub-rede usada pelo Cloud Run para sair para a VPC (output subnet_id do módulo network)."
}
