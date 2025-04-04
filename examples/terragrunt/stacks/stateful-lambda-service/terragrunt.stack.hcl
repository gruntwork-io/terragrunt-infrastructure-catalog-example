locals {
  name = "stateful-lambda-service"
}

unit "lambda_service" {
  source = "../../../../units/lambda-stateful-service"

  path = "service"

  values = {
    // This version here is used as the version passed down to the unit
    // to use when fetching the OpenTofu/Terraform module.
    version = "main"

    name = local.name

    // Required inputs
    runtime    = "provided.al2023"
    source_dir = "./src"
    handler    = "bootstrap"
    zip_file   = "handler.zip"

    // Optional inputs
    memory  = 128
    timeout = 3

    // Dependency paths
    role_path           = "../roles/lambda-iam-role-to-dynamodb"
    dynamodb_table_path = "../db"
  }
}

unit "db" {
  source = "../../../../units/dynamodb-table"

  path = "db"

  values = {
    // This version here is used as the version passed down to the unit
    // to use when fetching the OpenTofu/Terraform module.
    version = "main"

    name              = "${local.name}-db"
    hash_key          = "Id"
    hash_key_type     = "S"
  }
}

unit "role" {
  source = "../../../../units/lambda-iam-role-to-dynamodb"

  path = "roles/lambda-iam-role-to-dynamodb"

  values = {
    // This version here is used as the version passed down to the unit
    // to use when fetching the OpenTofu/Terraform module.
    version = "main"

    name = "${local.name}-role"

    dynamodb_table_path = "../../db"
  }
}
