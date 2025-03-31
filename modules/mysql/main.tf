# ---------------------------------------------------------------------------------------------------------------------
# CREATE A MYSQL DATABASE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_db_instance" "mysql" {
  engine         = "mysql"
  engine_version = var.engine_version

  db_name  = var.name
  username = var.master_username
  password = var.master_password

  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type

  skip_final_snapshot = var.skip_final_snapshot

  vpc_security_group_ids = [aws_security_group.db.id]
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP FOR THE MYSQL DATABASE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "db" {
  name = "${var.name}-db"
}

module "allow_outbound_all" {
  source = "../sg-rule"

  security_group_id = aws_security_group.db.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
