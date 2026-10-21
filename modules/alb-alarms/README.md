# ALB Alarms Module

This is an example OpenTofu/Terraform module that deploys [CloudWatch alarms](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/AlarmThatSendsEmail.html) for an [Application Load Balancer (ALB)](https://aws.amazon.com/elasticloadbalancing/application-load-balancer/), and an [SNS topic](https://aws.amazon.com/sns/) they notify. It alarms when the ALB returns 5XX errors, and when instances behind it fail health checks.

The module doesn't subscribe anything to the topic. Add a subscription (e.g. an email address or a paging service) to receive the notifications.

See the [root README](/README.md) for instructions on how to provision this module.

Note: This code is meant solely as a simple demonstration of how to lay out your files and folders with
[Terragrunt](https://github.com/gruntwork-io/terragrunt) in a way that keeps your [OpenTofu](https://opentofu.org/)
and [Terraform](https://www.terraform.io) code manageable. This is not production-ready code, so use at your own risk.
