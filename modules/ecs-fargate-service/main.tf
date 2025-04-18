# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN ECS FARGATE CLUSTER
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_cluster" "fargate" {
  name = var.name
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE ECS SERVICE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_service" "service" {
  name            = var.name
  cluster         = aws_ecs_cluster.fargate.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.service.arn

  load_balancer {
    container_name   = var.name
    container_port   = var.container_port
    target_group_arn = aws_lb_target_group.ecs.arn
  }

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [local.service_sg_id]
    assign_public_ip = true
  }

  # Ensure ALB is provisioned first
  depends_on = [aws_lb.ecs, aws_lb_listener.http, aws_lb_listener_rule.forward_all, aws_lb_target_group.ecs]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE ECS TASK DEFINITION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_ecs_task_definition" "service" {
  family                   = var.name
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions    = var.container_definitions
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  runtime_platform {
    cpu_architecture = var.cpu_architecture
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE IAM ROLE FOR ECS TASK EXECUTION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP FOR THE ECS SERVICE
# ---------------------------------------------------------------------------------------------------------------------

module "service_sg" {
  count = var.service_sg_id == null ? 1 : 0

  source = "../sg"

  name = "${var.name}-service"
}

locals {
  service_sg_id = var.service_sg_id == null ? module.service_sg[0].id : var.service_sg_id
}

module "allow_outbound_all" {
  source = "../sg-rule"

  security_group_id = local.service_sg_id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

module "allow_inbound_on_container_port" {
  source = "../sg-rule"

  security_group_id        = local.service_sg_id
  from_port                = var.container_port
  to_port                  = var.container_port
  source_security_group_id = local.alb_sg_id
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN ALB TO ROUTE TRAFFIC TO THE ECS SERVICE
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # An ALB can only be attached to one subnet per AZ, so filter the list of subnets to a unique one per AZ
  subnets_per_az  = { for subnet in data.aws_subnet.default : subnet.availability_zone => subnet.id... }
  subnets_for_alb = [for az, subnets in local.subnets_per_az : subnets[0]]
}

resource "aws_lb" "ecs" {
  name               = var.name
  load_balancer_type = "application"
  subnets            = local.subnets_for_alb
  security_groups    = [local.alb_sg_id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.ecs.arn
  port              = var.alb_port
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "ecs" {
  name_prefix = substr(var.name, 0, 6)
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener_rule" "forward_all" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP FOR THE ALB
# To keep the example simple, we configure the ALB to allow inbound requests from anywhere. We also allow it to make
# outbound requests to anywhere so it can perform health checks. In real-world usage, you should lock the ALB down
# so it only allows traffic to/from trusted sources.
# ---------------------------------------------------------------------------------------------------------------------

module "alb_sg" {
  count = var.alb_sg_id == null ? 1 : 0

  source = "../sg"

  name = "${var.name}-alb"
}

locals {
  alb_sg_id = var.alb_sg_id == null ? module.alb_sg[0].id : var.alb_sg_id
}

module "alb_allow_http_inbound" {
  source = "../sg-rule"

  security_group_id = local.alb_sg_id
  from_port         = var.alb_port
  to_port           = var.alb_port
  cidr_blocks       = ["0.0.0.0/0"]
}

module "alb_allow_all_outbound" {
  source = "../sg-rule"

  security_group_id = local.alb_sg_id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
