terraform {
  required_version = ">= 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "archive_file" "source_code" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/src.zip"
}

module "lambda_service" {
  source = "../../../modules/lambda-service"

  name     = var.name
  runtime  = "nodejs22.x"
  handler  = "index.handler"
  zip_file = data.archive_file.source_code.output_path
}
