include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../..//modules/lambda-service"
  update_source_with_cas = true
}

inputs = {
  # Required inputs
  name    = values.name
  runtime = values.runtime
  handler = values.handler

  s3_key = values.s3_key

  # Optional inputs
  memory  = try(values.memory, 128)
  timeout = try(values.timeout, 3)
}
