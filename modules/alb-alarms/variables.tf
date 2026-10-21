# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name used to namespace the SNS topic and alarms."
  type        = string
}

variable "alb_arn_suffix" {
  description = "The ARN suffix of the ALB to monitor (e.g. app/my-alb/1234567890abcdef)."
  type        = string
}

variable "target_group_arn_suffix" {
  description = "The ARN suffix of the target group to monitor (e.g. targetgroup/my-tg/1234567890abcdef)."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "elb_5xx_threshold" {
  description = "The number of 5XX responses from the ALB within one period that counts as a breach."
  type        = number
  default     = 10
}

variable "period" {
  description = "The length, in seconds, of each period the alarms evaluate."
  type        = number
  default     = 60
}

variable "evaluation_periods" {
  description = "The number of consecutive breaching periods before an alarm fires."
  type        = number
  default     = 5
}
