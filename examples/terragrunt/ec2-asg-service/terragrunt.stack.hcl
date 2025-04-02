unit "service" {
  source = "../../../units/ec2-asg-service"

  path = "service"

  values = {
    // This version here is used as the version passed down to the unit
    // to use when fetching the OpenTofu/Terraform module.
    version = "main"

    name          = "ec2-asg-service"
    instance_type = "t4g.micro"
    min_size      = 2
    max_size      = 4
    server_port   = 8080
    alb_port      = 80
  }
}
