variable "network" {
  type        = string
  description = "ID da VPC onde o Cloud SQL terá IP privado (output network_id do módulo network)."
}

variable "region" {
  type        = string
  description = "Região GCP da instância do Cloud SQL."
}

variable "name_instance_database" {
  type        = string
  description = "Nome da instância do Cloud SQL. Depois de apagada, o Google pode manter o nome reservado por cerca de uma semana."
}

variable "database_name" {
  type        = string
  description = "Nome do banco criado dentro da instância (prefira snake_case)."
}

variable "project" {
  type        = string
  description = "ID do projeto GCP onde o banco será criado."
}
