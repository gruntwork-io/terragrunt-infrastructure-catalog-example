# ECS Fargate Service Module

This is an example OpenTofu/Terraform module that deploys an [ECS Fargate Service](https://aws.amazon.com/ecs/) with an
[Application Load Balancer (ALB)](https://aws.amazon.com/elasticloadbalancing/application-load-balancer/) in front of
it. See the [root README](/README.md) for instructions on how to provision this module.

Note: This code is meant solely as a simple demonstration of how to lay out your files and folders with
[Terragrunt](https://github.com/gruntwork-io/terragrunt) in a way that keeps your [OpenTofu](https://opentofu.org/)
and [Terraform](https://www.terraform.io) code manageable. This is not production-ready code, so use at your own risk.
