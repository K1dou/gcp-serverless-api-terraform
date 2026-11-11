output "db_instance_name" {
  value       = google_sql_database_instance.instance.name
  description = "O nome da instância do Cloud SQL (necessário para permissões de IAM)"
}

output "db_private_ip" {
  value       = google_sql_database_instance.instance.private_ip_address
  description = "O IP privado do banco de dados (o Cloud Run vai usar para conectar)"
}

output "secret_id" {
  value       = google_secret_manager_secret.db_secret.id
  description = "O ID do recurso do Secret Manager onde a senha está guardada"
}

output "secret_name" {
  value       = google_secret_manager_secret.db_secret.secret_id
  description = "O nome descritivo do segredo"
}

output "db_url_secret_id" {
  value       = google_secret_manager_secret.api_db_url_secret.secret_id
  description = "ID do segredo com a URL de conexão (DATABASE_URL) que a API lê."
}

output "db_url_secret_version" {
  value       = google_secret_manager_secret_version.api_db_url_version.version
  description = "Número da versão do segredo da URL de conexão. Depender dele garante que a versão exista antes do Cloud Run."
}
