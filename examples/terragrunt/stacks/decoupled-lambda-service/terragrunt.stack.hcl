locals {
  name = "decoupled-lambda-service"

  s3_key = "handler.zip"
}

unit "lambda_service" {
  source = "../../../../units/lambda-decoupled-service"

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

    s3_key = local.s3_key

    // Optional inputs
    memory  = 128
    timeout = 3

    // Dependency paths
    s3_path = "../s3"
  }
}

unit "s3" {
  source = "../../../../units/lambda-artifact-s3-bucket"

  path = "s3"

  values = {
    // This version here is used as the version passed down to the unit
    // to use when fetching the OpenTofu/Terraform module.
    version = "main"

    name = "${local.name}-s3"

    force_destroy = true

    s3_key = local.s3_key
    src_path = "${get_repo_root()}/examples/app/lambda-decoupled-artifact/src"
    package_script = "${get_repo_root()}/examples/app/lambda-decoupled-artifact/scripts/package.sh"
    package_path = "${get_repo_root()}/examples/app/lambda-decoupled-artifact/handler.zip"
  }
}
