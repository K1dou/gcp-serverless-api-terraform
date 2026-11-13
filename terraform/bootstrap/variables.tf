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
  type = string
}

variable "github_repository_owner_id" {
  type = string
}