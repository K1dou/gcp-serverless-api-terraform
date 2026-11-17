variable "project" {
  type        = string
  description = "ID do projeto GCP."
}

variable "region" {
  type        = string
  description = "Região do Cloud Run e do job de migrations."
}

variable "cloud_run_name" {
  type        = string
  description = "Nome do serviço Cloud Run em que a deploy-sa pode fazer deploy."
}

variable "migrate_job_name" {
  type        = string
  description = "Nome do Cloud Run Job de migrations que a deploy-sa pode atualizar e executar."
}

variable "api_sa_name" {
  type        = string
  description = "Nome da service account da API; a deploy-sa precisa de serviceAccountUser nela."
}

variable "repository_name" {
  type        = string
  description = "Nome do repositório do Artifact Registry onde a deploy-sa envia imagens."
}

variable "github_repository" {
  type        = string
  description = "Repositório GitHub autorizado a assumir a deploy-sa, no formato dono/repo."
}

variable "pool_name" {
  type        = string
  description = "Nome completo do Workload Identity Pool (projects/NÚMERO/locations/global/workloadIdentityPools/ID), vindo do bootstrap."
}
