variable "region" {
  type        = string
  description = "Região GCP do Cloud Run e do Artifact Registry."
}

variable "repository_id" {
  type        = string
  description = "ID do repositório de imagens de container no Artifact Registry."
}

variable "db_url_secret_id" {
  type        = string
  description = "ID do segredo com a URL de conexão do banco (output db_url_secret_id do módulo database). A api-sa recebe permissão de leitura nele."
}

variable "db_url_secret_version" {
  type        = string
  description = "Versão do segredo da URL de conexão (output db_url_secret_version do módulo database)."
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

variable "cloud_run_name" {
  type        = string
  description = "Nome para o serviço cloud Run "
}

variable "container_image" {
  type        = string
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
  description = "imagem inicial do Cloud Run,imagem real é feito pelo pipeline"
}
