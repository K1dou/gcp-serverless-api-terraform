variable "project_id" {
  type        = string
  description = "ID do projeto GCP onde o bucket do state será criado."
}

variable "location" {
  type        = string
  description = "Localização do bucket de state."
  default     = "us-central1"
}

variable "bucket_name" {
  type        = string
  description = "Nome do bucket de state (único globalmente)."
}

variable "github_repository" {
  type        = string
  description = "Repositório GitHub aceito pelo provider do WIF, no formato dono/repo."
}

variable "github_repository_owner_id" {
  type        = string
  description = "ID numérico do dono do repositório no GitHub; o provider rejeita tokens de outros donos."
}

variable "billing_account" {
  type        = string
  description = "ID da conta de billing (formato XXXXXX-XXXXXX-XXXXXX) onde o orçamento é criado. Fica no terraform.tfvars, fora do Git."
}

variable "alert_email" {
  type        = string
  description = "E-mail que recebe os alertas de custo. Fica no terraform.tfvars, fora do Git."
}