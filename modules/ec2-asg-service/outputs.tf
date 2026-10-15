output "url" {
  value = "http://${aws_lb.lb.dns_name}:${var.alb_port}"
}

output "alb_dns_name" {
  value = aws_lb.lb.dns_name
}

output "alb_arn_suffix" {
  value = aws_lb.lb.arn_suffix
}

output "target_group_arn_suffix" {
  value = aws_lb_target_group.target_group.arn_suffix
}

output "asg_name" {
  value = aws_autoscaling_group.asg.name
}

output "asg_security_group_id" {
  value = local.asg_sg_id
}

output "alb_security_group_id" {
  value = local.alb_sg_id
}
