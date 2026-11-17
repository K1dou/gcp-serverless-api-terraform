resource "google_monitoring_notification_channel" "basic" {
  display_name = "Alertas API dev"
  type         = "email"
  labels = {
    email_address = var.alert_email
  }
  force_delete = false
}

resource "google_monitoring_uptime_check_config" "uptime_check_api" {
  display_name       = "uptime_check_api"
  timeout            = "60s"
  log_check_failures = true


  http_check {
    path           = "/health"
    port           = 443
    use_ssl        = true
    request_method = "GET"
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project
      host       = trimprefix(var.api_final_url, "https://")
    }
  }
}

resource "google_monitoring_alert_policy" "uptime_failing" {
  display_name = "uptime_failing"
  combiner     = "OR"

  conditions {
    display_name = "Uptime check falhou em mais de um local"

    condition_threshold {
      filter = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.label.check_id=\"${google_monitoring_uptime_check_config.uptime_check_api.uptime_check_id}\" AND resource.type=\"uptime_url\""

      comparison      = "COMPARISON_GT"
      threshold_value = 1

      duration = "60s"

      aggregations {
        alignment_period     = "1200s"
        per_series_aligner   = "ALIGN_NEXT_OLDER"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields      = ["resource.label.*"]
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.basic.id]
}

resource "google_monitoring_alert_policy" "api_5xx" {
  display_name = "api_5xx"
  combiner     = "OR"

  conditions {
    display_name = "alerta 5xx"

    condition_threshold {
      filter = "metric.type=\"run.googleapis.com/request_count\" AND resource.type=\"cloud_run_revision\" AND resource.label.service_name=\"${var.cloud_run_name}\" AND metric.label.response_code_class=\"5xx\""

      comparison      = "COMPARISON_GT"
      threshold_value = 0

      duration = "0s"

      aggregations {
        alignment_period     = "300s"
        per_series_aligner   = "ALIGN_DELTA"
        cross_series_reducer = "REDUCE_SUM"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.basic.id]
}


