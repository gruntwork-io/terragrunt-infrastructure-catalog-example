# ---------------------------------------------------------------------------------------------------------------------
# USE THE DEFAULT VPC AND SUBNETS
# To keep this example simple, we use the default VPC and subnets, but in real-world code, you'll want to use a
# custom VPC.
# ---------------------------------------------------------------------------------------------------------------------

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "default" {
  count = length(data.aws_subnets.default.ids)
  id    = data.aws_subnets.default.ids[count.index]
}

# ---------------------------------------------------------------------------------------------------------------------
# LOOK UP THE AMAZON LINUX AMI ID
# ---------------------------------------------------------------------------------------------------------------------

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "image-type"
    values = ["machine"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# LOOK UP THE INSTANCE TYPE OFFERINGS
# ---------------------------------------------------------------------------------------------------------------------

data "aws_ec2_instance_type_offerings" "offerings" {
  for_each = toset(data.aws_subnet.default[*].availability_zone)

  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }
  filter {
    name   = "location"
    values = [each.key]
  }

  location_type = "availability-zone"
}
