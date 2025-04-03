output "url" {
  value = "http://${aws_lb.ecs.dns_name}:${var.alb_port}"
}

output "alb_dns_name" {
  value = aws_lb.ecs.dns_name
}

output "service_security_group_id" {
  value = local.service_sg_id
}

output "alb_security_group_id" {
  value = local.alb_sg_id
}
