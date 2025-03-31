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
}
