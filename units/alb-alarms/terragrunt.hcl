include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../..//modules/alb-alarms"
  update_source_with_cas = true
}

inputs = {
  # Required inputs
  name = values.name

  # Optional inputs
  elb_5xx_threshold  = try(values.elb_5xx_threshold, 10)
  period             = try(values.period, 60)
  evaluation_periods = try(values.evaluation_periods, 5)
}
