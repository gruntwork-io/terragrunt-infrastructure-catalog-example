<!-- Frontmatter
tags: [gcp]
-->

# GCP App Foundation Stack

This is an example Terragrunt stack that provisions the pieces an application needs before it can run: a
[Cloud Storage bucket](https://cloud.google.com/storage/docs/buckets), a
[Firestore database](https://cloud.google.com/firestore/docs/overview), an
[Artifact Registry repository](https://cloud.google.com/artifact-registry/docs/overview), the
[service account](https://cloud.google.com/iam/docs/service-account-overview) the application runs as, and optional
[Cloud Monitoring alert policies](https://cloud.google.com/monitoring/alerts). See the
[GCP App Foundation example](/examples/terragrunt/gcp/stacks/app-foundation) for instructions on how to provision this stack.

Note: This code is meant solely as a simple demonstration of how to lay out your files and folders with
[Terragrunt](https://github.com/gruntwork-io/terragrunt) in a way that keeps your [OpenTofu](https://opentofu.org/)
and [Terraform](https://www.terraform.io) code manageable. This is not production-ready code, so use at your own risk.
