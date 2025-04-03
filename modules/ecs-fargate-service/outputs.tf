output "url" {
  value = "http://${aws_lb.ecs.dns_name}:${var.alb_port}"
}

output "alb_dns_name" {
  value = aws_lb.ecs.dns_name
}

output "service_security_group_id" {
  value = aws_security_group.service.id
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}
