# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN SNS TOPIC FOR ALARM NOTIFICATIONS
# Subscribe to this topic (e.g. by email or from a paging service) to get notified when an alarm fires.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_sns_topic" "alarms" {
  name = "${var.name}-alarms"
}

# ---------------------------------------------------------------------------------------------------------------------
# ALARM WHEN THE ALB RETURNS 5XX ERRORS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "elb_5xx" {
  alarm_name        = "${var.name}-elb-5xx"
  alarm_description = "The ALB for ${var.name} is returning 5XX errors."

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_ELB_5XX_Count"
  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  statistic           = "Sum"
  period              = var.period
  evaluation_periods  = var.evaluation_periods
  threshold           = var.elb_5xx_threshold
  comparison_operator = "GreaterThanOrEqualToThreshold"

  # The ALB publishes no data points while it serves no 5XX responses.
  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
}

# ---------------------------------------------------------------------------------------------------------------------
# ALARM WHEN INSTANCES BEHIND THE ALB FAIL HEALTH CHECKS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name        = "${var.name}-unhealthy-hosts"
  alarm_description = "Instances behind the ALB for ${var.name} are failing health checks."

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"
  dimensions = {
    LoadBalancer = var.alb_arn_suffix
    TargetGroup  = var.target_group_arn_suffix
  }

  statistic           = "Maximum"
  period              = var.period
  evaluation_periods  = var.evaluation_periods
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.alarms.arn]
  ok_actions    = [aws_sns_topic.alarms.arn]
}
