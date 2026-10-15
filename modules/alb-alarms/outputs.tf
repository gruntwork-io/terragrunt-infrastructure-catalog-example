output "sns_topic_arn" {
  value = aws_sns_topic.alarms.arn
}

output "elb_5xx_alarm_name" {
  value = aws_cloudwatch_metric_alarm.elb_5xx.alarm_name
}

output "unhealthy_hosts_alarm_name" {
  value = aws_cloudwatch_metric_alarm.unhealthy_hosts.alarm_name
}
