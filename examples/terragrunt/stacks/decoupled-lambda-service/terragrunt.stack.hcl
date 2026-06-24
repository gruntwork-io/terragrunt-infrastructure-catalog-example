locals {
  name = "decoupled-lambda-service"

  s3_key = "handler.zip"
}

unit "lambda_service" {
  // The `//` marks the repository root. That context lets each generated unit
  // properly use `update_source_with_cas` to find its relative paths within the
  // catalog and materialize them from the CAS.
  source = "../../../..//units/lambda-decoupled-service"

  path = "service"

  values = {
    name = local.name

    // Required inputs
    runtime    = "provided.al2023"
    source_dir = "./src"
    handler    = "bootstrap"

    s3_key = local.s3_key

    // Optional inputs
    memory  = 128
    timeout = 3
  }

  autoinclude {
    dependency "s3" {
      config_path = unit.s3.path

      mock_outputs = {
        name = "s3-bucket"
      }
    }

    inputs = {
      s3_bucket         = dependency.s3.outputs.name
      s3_object_version = run_cmd("--terragrunt-quiet", "scripts/handler-discovery.sh", dependency.s3.outputs.name, values.s3_key)

      environment_variables = {
        VERSION = run_cmd("--terragrunt-quiet", "scripts/handler-discovery.sh", dependency.s3.outputs.name, values.s3_key)
      }
    }
  }
}

unit "s3" {
  source = "../../../..//units/lambda-artifact-s3-bucket"

  path = "s3"

  values = {
    name = "${local.name}-s3"

    force_destroy = true

    s3_key         = local.s3_key
    src_path       = "${get_repo_root()}/examples/app/lambda-decoupled-artifact/src"
    package_script = "${get_repo_root()}/examples/app/lambda-decoupled-artifact/scripts/package.sh"
    package_path   = "${get_repo_root()}/examples/app/lambda-decoupled-artifact/handler.zip"
  }
}
