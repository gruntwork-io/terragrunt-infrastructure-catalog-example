output "alert_policy_names" {
  description = "The display names of the alert policies, keyed by the short name given in metric_alerts"
  value       = { for key, alert in google_monitoring_alert_policy.alert : key => alert.display_name }
}

output "alert_policy_ids" {
  description = "The full resource paths of the alert policies, keyed by the short name given in metric_alerts"
  value       = { for key, alert in google_monitoring_alert_policy.alert : key => alert.name }
}

output "notification_channel_ids" {
  description = "The full resource paths of the email notification channels, keyed by email address"
  value       = { for email, channel in google_monitoring_notification_channel.email : email => channel.name }
}
