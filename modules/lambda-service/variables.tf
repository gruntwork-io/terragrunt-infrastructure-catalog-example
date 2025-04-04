# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "runtime" {
  description = "The Lambda runtime to use. Must be one of the values in: https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html"
  type        = string
}

variable "handler" {
  description = "The function entrypoint in your code"
  type        = string
}

variable "zip_file" {
  description = "The path to the zip file containing the Lambda function code"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "memory" {
  description = "The amount of memory, in MB, to assign to the function. This also determines the CPU available. See: https://docs.aws.amazon.com/lambda/latest/dg/configuration-function-common.html#configuration-memory-console."
  type        = number
  default     = 128
}

variable "timeout" {
  description = "The amount of time, in seconds, your function has to run. Max is 900 seconds (15 min)."
  type        = number
  default     = 3
}

variable "authorization_type" {
  description = "The type of authorization used for the Lambda function URL. Valid values are 'NONE' or 'AWS_IAM'"
  type        = string
  default     = "NONE"
}

variable "iam_role_arn" {
  description = "The ARN of the IAM role to use for the Lambda function"
  type        = string
  default     = null
}

variable "environment_variables" {
  description = "A map of environment variables to pass to the Lambda function"
  type        = map(string)
  default     = null
}

variable "architectures" {
  description = "The architectures to support for the Lambda function"
  type        = list(string)
  default     = ["arm64"]
}
