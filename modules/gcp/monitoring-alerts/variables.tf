# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name used to namespace the alert policies and notification channels."
  type        = string
}

variable "resource_filter" {
  description = "The Cloud Monitoring filter that selects the resource to watch (e.g. resource.type = \"gcs_bucket\" AND resource.label.bucket_name = \"my-bucket\")"
  type        = string
}

variable "metric_alerts" {
  description = "The alert policies to create, keyed by a short name used in the policy name. Set filter to narrow the metric further (e.g. metric.label.response_code != \"OK\")."
  type = map(object({
    metric_type = string
    comparison  = string
    threshold   = number
    aligner     = optional(string, "ALIGN_RATE")
    filter      = optional(string)
    description = optional(string)
    severity    = optional(string, "WARNING")
  }))
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "email_addresses" {
  description = "The email addresses to notify when an alert fires or resolves"
  type        = list(string)
  default     = []
}

variable "alignment_period" {
  description = "The period each data point is aggregated over before it is compared to the threshold (e.g. 60s)"
  type        = string
  default     = "60s"
}

variable "duration" {
  description = "How long the metric must cross the threshold before the alert fires (e.g. 300s)"
  type        = string
  default     = "300s"
}

variable "labels" {
  description = "Labels to apply to the alert policies and notification channels"
  type        = map(string)
  default     = {}
}
