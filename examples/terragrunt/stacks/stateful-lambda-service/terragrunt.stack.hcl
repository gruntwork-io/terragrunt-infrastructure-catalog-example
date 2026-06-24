locals {
  name = "stateful-lambda-service"
}

unit "lambda_service" {
  // The `//` marks the repository root. That context lets each generated unit
  // properly use `update_source_with_cas` to find its relative paths within the
  // catalog and materialize them from the CAS.
  source = "../../../..//units/lambda-stateful-service"

  path = "service"

  values = {
    name = local.name

    // Required inputs
    runtime    = "provided.al2023"
    source_dir = "./src"
    handler    = "bootstrap"
    zip_file   = "handler.zip"

    // Optional inputs
    memory  = 128
    timeout = 3
  }

  autoinclude {
    dependency "role" {
      config_path = unit.role.path

      mock_outputs = {
        arn = "arn:aws:iam::123456789012:role/lambda-iam-role-to-dynamodb"
      }
    }

    dependency "dynamodb_table" {
      config_path = unit.db.path

      mock_outputs = {
        name = "dynamodb-table"
      }
    }

    inputs = {
      iam_role_arn = dependency.role.outputs.arn

      environment_variables = {
        DYNAMODB_TABLE = dependency.dynamodb_table.outputs.name
      }
    }
  }
}

unit "db" {
  source = "../../../..//units/dynamodb-table"

  path = "db"

  values = {
    name          = "${local.name}-db"
    hash_key      = "Id"
    hash_key_type = "S"
  }
}

unit "role" {
  source = "../../../..//units/lambda-iam-role-to-dynamodb"

  path = "roles/lambda-iam-role-to-dynamodb"

  values = {
    name = "${local.name}-role"
  }

  autoinclude {
    dependency "dynamodb_table" {
      config_path = unit.db.path

      mock_outputs = {
        arn = "arn:aws:dynamodb:us-east-1:123456789012:table/example-table"
      }
    }

    inputs = {
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action = [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
            ]
            Effect   = "Allow"
            Resource = "arn:aws:logs:*:*:*"
          },
          {
            Action = [
              "dynamodb:GetItem",
              "dynamodb:PutItem",
              "dynamodb:UpdateItem",
              "dynamodb:DeleteItem"
            ]
            Effect   = "Allow"
            Resource = dependency.dynamodb_table.outputs.arn
          }
        ]
      })
    }
  }
}
