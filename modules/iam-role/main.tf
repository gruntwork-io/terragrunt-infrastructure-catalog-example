resource "aws_iam_role" "lambda" {
  name               = var.name
  assume_role_policy = var.assume_role_policy
}

resource "aws_iam_role_policy" "policy" {
  name   = var.name
  role   = aws_iam_role.lambda.name
  policy = var.policy
}
