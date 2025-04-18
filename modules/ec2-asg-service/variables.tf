# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name for the ASG. This name is also used to namespace all the other resources created by this module."
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 Instnaces to run in the ASG (e.g. t2.micro)"
  type        = string
}

variable "min_size" {
  description = "The minimum number of EC2 Instances to run in the ASG"
  type        = number
}

variable "max_size" {
  description = "The maximum number of EC2 Instances to run in the ASG"
  type        = number
}

variable "server_port" {
  description = "The port number the web server on each EC2 Instance should listen on for HTTP requests"
  type        = number
}

variable "alb_port" {
  description = "The port number the ALB should listen on for HTTP requests"
  type        = number
}

variable "user_data" {
  description = "The user data to pass to the instances"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "asg_sg_id" {
  description = "The ID of the security group for the ASG"
  type        = string
  default     = null
}

variable "alb_sg_id" {
  description = "The ID of the security group for the ALB"
  type        = string
  default     = null
}
