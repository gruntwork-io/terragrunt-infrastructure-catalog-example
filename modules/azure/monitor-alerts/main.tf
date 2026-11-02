# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN ACTION GROUP FOR ALERT NOTIFICATIONS
# Add email receivers (or wire up a paging service) to get notified when an alert fires.
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_monitor_action_group" "alerts" {
  name                = "${var.name}-alerts"
  resource_group_name = var.resource_group_name

  # Azure caps the short name at 12 characters. It shows up in email and SMS notifications.
  short_name = substr(replace(var.name, "-", ""), 0, 12)

  dynamic "email_receiver" {
    for_each = var.email_addresses

    content {
      name                    = "email-${email_receiver.key}"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE METRIC ALERTS
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_monitor_metric_alert" "alert" {
  for_each = var.metric_alerts

  name                = "${var.name}-${each.key}"
  resource_group_name = var.resource_group_name
  scopes              = [var.target_resource_id]
  description         = each.value.description
  severity            = each.value.severity
  frequency           = var.frequency
  window_size         = var.window_size

  criteria {
    metric_namespace = var.metric_namespace
    metric_name      = each.value.metric_name
    aggregation      = each.value.aggregation
    operator         = each.value.operator
    threshold        = each.value.threshold
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }

  tags = var.tags
}
