# ---------------------------------------------------------------------------------------------------------------------
# CREATE A NOTIFICATION CHANNEL FOR EACH EMAIL ADDRESS
# Add more channel types (or connect a paging service) to get notified some other way when an alert fires.
# ---------------------------------------------------------------------------------------------------------------------

resource "google_monitoring_notification_channel" "email" {
  for_each = toset(var.email_addresses)

  display_name = "${var.name}-${each.value}"
  type         = "email"

  labels = {
    email_address = each.value
  }

  user_labels = var.labels
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE ALERT POLICIES
# ---------------------------------------------------------------------------------------------------------------------

resource "google_monitoring_alert_policy" "alert" {
  for_each = var.metric_alerts

  display_name = "${var.name}-${each.key}"
  combiner     = "OR"
  severity     = each.value.severity

  conditions {
    display_name = "${var.name}-${each.key}"

    condition_threshold {
      filter          = join(" AND ", compact(["metric.type = \"${each.value.metric_type}\"", var.resource_filter, each.value.filter]))
      comparison      = each.value.comparison
      threshold_value = each.value.threshold
      duration        = var.duration

      aggregations {
        alignment_period   = var.alignment_period
        per_series_aligner = each.value.aligner
      }
    }
  }

  dynamic "documentation" {
    for_each = each.value.description == null ? [] : [each.value.description]

    content {
      content   = documentation.value
      mime_type = "text/markdown"
    }
  }

  notification_channels = [for channel in google_monitoring_notification_channel.email : channel.id]

  user_labels = var.labels
}
