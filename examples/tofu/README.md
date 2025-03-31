# OpenTofu Examples

This directory contains examples using the OpenTofu modules in this repository directly.

It does not use Terragrunt, and doesn't assume any specific Terragrunt configuration.

These examples are useful for testing the modules in isolation, only considering OpenTofu code, and determining the best way to make OpenTofu modules generic enough that they're viable for use and re-use in many different contexts.

## Running the examples

1. Open `variables.tf` and update variables as necessary.
2. Run `tofu init`.
3. Run `tofu apply`.
4. When you're done testing, run `tofu destroy`.
