# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED VARIABLES
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name used to namespace the action group and alerts."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to create the action group and alerts in"
  type        = string
}

variable "target_resource_id" {
  description = "The ID of the resource to monitor"
  type        = string
}

variable "metric_namespace" {
  description = "The metric namespace of the monitored resource (e.g. Microsoft.Storage/storageAccounts)"
  type        = string
}

variable "metric_alerts" {
  description = "The metric alerts to create, keyed by a short name used in the alert name."
  type = map(object({
    metric_name = string
    aggregation = string
    operator    = string
    threshold   = number
    description = optional(string)
    severity    = optional(number, 2)
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

variable "frequency" {
  description = "How often the alerts are evaluated, as an ISO 8601 duration (e.g. PT1M)"
  type        = string
  default     = "PT1M"
}

variable "window_size" {
  description = "The period of time each evaluation looks back over, as an ISO 8601 duration (e.g. PT5M)"
  type        = string
  default     = "PT5M"
}

variable "tags" {
  description = "Tags to apply to the action group and alerts"
  type        = map(string)
  default     = {}
}
