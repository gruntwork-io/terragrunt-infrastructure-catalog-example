output "action_group_id" {
  description = "The ID of the action group that receives the alert notifications"
  value       = azurerm_monitor_action_group.alerts.id
}

output "metric_alert_names" {
  description = "The names of the metric alerts, keyed by the short name given in metric_alerts"
  value       = { for key, alert in azurerm_monitor_metric_alert.alert : key => alert.name }
}
