output "db_instance_name" {
  value       = google_sql_database_instance.instance.name
  description = "O nome da instância do Cloud SQL (necessário para permissões de IAM)"
}

output "db_private_ip" {
  value       = google_sql_database_instance.instance.private_ip_address
  description = "O IP privado do banco de dados (o Cloud Run vai usar para conectar)"
}

output "secret_id" {
  value       = google_secret_manager_regional_secret.regional-secret-cloud-sql-db-credentials.id
  description = "O ID do recurso do Secret Manager onde a senha está guardada"
}

output "secret_name" {
  value       = google_secret_manager_regional_secret.regional-secret-cloud-sql-db-credentials.secret_id
  description = "O nome descritivo do segredo"
}