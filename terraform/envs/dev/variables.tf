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
  type = string
}

variable "github_repository_owner_id" {
  type = string
}