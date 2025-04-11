# Migrating from the `terragrunt-infrastructure-modules-example` repository

If you have an existing repository that was started using the [terragrunt-infrastructure-modules-example](https://github.com/gruntwork-io/terragrunt-infrastructure-modules-example) repository as a starting point, follow the steps below to migrate your existing configurations to take advantage of the patterns outlined in this repository.

## Step 1: Assess your current infrastructure patterns

Look at the existing configurations in your `infrastructure-live` repository, and see if there are any common patterns that you can extract into a catalog.

During this step, try to take note of any common collections of `terragrunt.hcl` files that you repeatedly duplicate across environments, accounts, regions, etc.

## Step 2: Start to extract common stacks into a catalog

Follow the steps in the [terragrunt-infrastructure-live-stacks-example migration guide](https://github.com/gruntwork-io/terragrunt-infrastructure-live-stacks-example/blob/main/docs/migration-guide.md) to start extracting common stacks out from your `infrastructure-live` repository into a catalog.

## Step 3: Start testing your units and stacks

Take a look at the tests in [test/terragrunt](/test/terragrunt) and use those patterns to start testing your units and stacks to confirm that they're reliably reproducible.
