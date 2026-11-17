output "notification_channel_id" {
  description = "ID do canal de e-mail, usado pelas alert policies."
  value       = google_monitoring_notification_channel.basic.id
}

output "uptime_check_id" {
  description = "ID do uptime check da API."
  value       = google_monitoring_uptime_check_config.uptime_check_api.uptime_check_id
}
