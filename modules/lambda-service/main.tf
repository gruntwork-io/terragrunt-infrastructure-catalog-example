# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------



resource "aws_lambda_function" "function" {
  function_name = var.name
  role          = local.iam_role_arn

  package_type     = "Zip"
  filename         = var.zip_file
  source_code_hash = filesha256(var.zip_file)

  runtime = var.runtime
  handler = var.handler

  memory_size = var.memory
  timeout     = var.timeout

  architectures = var.architectures

  dynamic "environment" {
    // Hack to allow for optional environment variables.
    for_each = var.environment_variables == null ? [true] : []
    content {
      variables = var.environment_variables
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE IAM ROLE IF NOT PROVIDED
# ---------------------------------------------------------------------------------------------------------------------

locals {
  iam_role_arn = var.iam_role_arn == null ? aws_iam_role.lambda[0].arn : var.iam_role_arn
}

resource "aws_iam_role" "lambda" {
  count = var.iam_role_arn == null ? 1 : 0

  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.policy[0].json
}

data "aws_iam_policy_document" "policy" {
  count = var.iam_role_arn == null ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A LAMBDA FUNCTION URL
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_function_url" "function_url" {
  function_name      = aws_lambda_function.function.function_name
  authorization_type = var.authorization_type
}

# ---------------------------------------------------------------------------------------------------------------------
# ALLOW LAMBDA URL TO INVOKE THE FUNCTION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_permission" "allow_url_invoke" {
  statement_id           = "AllowFunctionURLInvoke"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = aws_lambda_function.function.function_name
  principal              = "*"
  function_url_auth_type = var.authorization_type
}
