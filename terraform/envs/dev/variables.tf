variable "project_id" {
  type        = string
  description = "ID do projeto GCP onde o bucket do state será criado."
}

variable "region" {
  type        = string
  description = "Localização do bucket de state."
  default     = "us-central1"
}





