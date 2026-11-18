variable "project_id" {
  type        = string
  description = "ID do projeto GCP onde os recursos do ambiente dev são criados."
}

variable "region" {
  type        = string
  description = "Região padrão dos recursos do ambiente dev."
  default     = "us-central1"
}

variable "github_repository" {
  type        = string
  description = "Repositório GitHub no formato dono/repo."
}

variable "github_repository_owner_id" {
  type        = string
  description = "ID numérico do dono do repositório no GitHub."
}

variable "alert_email" {
  type        = string
  description = "E-mail que recebe os alertas de monitoramento. Fica no terraform.tfvars, fora do Git."
}