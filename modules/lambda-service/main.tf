# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_function" "function" {
  function_name = var.name
  role          = aws_iam_role.lambda.arn

  package_type     = "Zip"
  filename         = var.zip_file
  source_code_hash = filesha256(var.zip_file)

  runtime = var.runtime
  handler = var.handler

  memory_size = var.memory
  timeout     = var.timeout
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE IAM ROLE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "lambda" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.policy.json
}

data "aws_iam_policy_document" "policy" {
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
