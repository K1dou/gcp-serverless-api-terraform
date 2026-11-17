variable "project" {
  type        = string
  description = "ID do projeto GCP onde o monitoramento é criado."
}

variable "api_final_url" {
  type        = string
  description = "URL pública do Cloud Run, com https:// (o módulo tira o prefixo para obter o host do uptime check)."
}

variable "cloud_run_name" {
  type        = string
  description = "Nome do serviço Cloud Run cujos erros 5xx são monitorados."
}

variable "alert_email" {
  type        = string
  description = "E-mail que recebe os alertas. Fica no terraform.tfvars, fora do Git."
}
