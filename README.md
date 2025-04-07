[![Maintained by Gruntwork.io](https://img.shields.io/badge/maintained%20by-gruntwork.io-%235849a6.svg)](https://gruntwork.io/?ref=repo_terragrunt-infrastructure-catalog-example)

# Example infrastructure-catalog for Terragrunt

This repository, along with the [terragrunt-infrastructure-live-stacks-example repository](https://github.com/gruntwork-io/terragrunt-infrastructure-live-stacks-example), offers a set of best practice infrastructure configurations for setting up a catalog for your infrastructure.

An `infrastructure-catalog` is a repository that contains the best practice infrastructure patterns you or your organization wants to use across your [infrastructure estate](https://terragrunt.gruntwork.io/docs/getting-started/terminology/#infrastructure-estate). This is a Git repository that is vetted, and tested to reliably provision the infrastructure patterns you need. You typically version this repository using [Semantic Versioning](https://semver.org/) to communicate how changes to infrastructure patterns will impact consumption in your infrastructure estate.

If you have not already done so, you are encouraged to read the [Terragrunt Getting Started Guide](https://terragrunt.gruntwork.io/docs/getting-started/quick-start/) to get familiar with the terminology and concepts used in this repository before proceeding.

## Usage

To use this repository, you'll want to fork this repository into your own Git organization.

The steps for doing this are the following:

1. Create a new Git repository in your organization (e.g. [GitHub](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository), [GitLab](https://docs.gitlab.com/user/project/repository/)).

   **Note**: You typically shouldn't have any sensitive information in this repository, as it will only contain generic infrastructure patterns that can be provisioned in any environment, but you might want to have this repository be private regardless.

2. Create a bare clone of this repository somewhere on your local machine.

   ```bash
   git clone --bare https://github.com/gruntwork-io/terragrunt-infrastructure-modules-example.git
   ```

3. Push the bare clone to your new Git repository.

   ```bash
   cd terragrunt-infrastructure-modules-example.git
   git push --mirror <YOUR_GIT_REPO_URL> # e.g. git push --mirror git@github.com:acme/terragrunt-infrastructure-catalog-example.git
   ```

4. Remove the local clone of the repository.

   ```bash
   cd ..
   rm -rf terragrunt-infrastructure-modules-example.git
   ```

5. (Optional) Delete the contents of this usage documentation from your fork of this repository.

6. (Optional) Create a release for the new repository (e.g. [GitHub](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository), [GitLab](https://docs.gitlab.com/user/project/releases/)). You'll want to do this early and often as you make changes to the infrastructure patterns in your fork.

## Prerequisites

To use this repository, you'll want to make sure you have the following installed:

- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/)
- [OpenTofu](https://opentofu.org/docs/intro/install/) (or [Terraform](https://developer.hashicorp.com/terraform/install))
- [Go](https://go.dev/doc/install)

To simplify the process of installing these tools, you can install [mise](https://mise.jdx.dev/), then run the following to concurrently install all the tools you need, pinned to the versions they were tested with (as tracked in the [mise.toml](./mise.toml) file):

```bash
mise install
```

For background information on Terragrunt, read the [Getting Started Guide](https://terragrunt.gruntwork.io/docs/getting-started/overview/).

## Repository Contents

> **Note**: This code is solely for demonstration purposes. This is not production-ready code, so use at your own risk. If you are interested in battle-tested, production-ready Terragrunt and OpenTofu/Terraform code, continuously updated and maintained by a team of subject matter experts, consider purchasing a subscription to the [Gruntwork IaC Library](https://www.gruntwork.io/platform/iac-library).

This repository contains the following components to help you get started on building out your own infrastructure catalog:

### OpenTofu Modules

- [ec2-asg-service](/modules/ec2-asg-service): An example OpenTofu module that provisions an AWS EC2 Auto Scaling Group (ASG) with an Application Load Balancer (ALB) in front of it.
- [ecr-repository](/modules/ecr-repository): An example OpenTofu module that provisions an Amazon Elastic Container Registry (ECR) repository.
- [ecs-fargate-service](/modules/ecs-fargate-service): An example OpenTofu module that provisions an AWS ECS Fargate service for a containerized application.
- [iam-role](/modules/iam-role): An example OpenTofu module that provisions an AWS IAM role with configurable policies.
- [lambda-service](/modules/lambda-service): An example OpenTofu module that provisions an AWS Lambda function and a Lambda function URL to trigger it.
- [mysql](/modules/mysql): An example OpenTofu module that provisions a MySQL database using Relational Database Service (RDS).
- [s3-bucket](/modules/s3-bucket): An example OpenTofu module that provisions an S3 bucket.
- [sg](/modules/sg): An example OpenTofu module that provisions a security group.
- [sg-rule](/modules/sg-rule): An example OpenTofu module that provisions security group rules.
- [dynamodb-table](/modules/dynamodb-table): An example OpenTofu module that provisions a DynamoDB table.

### Terragrunt Units

- [ec2-asg-stateful-service](/units/ec2-asg-stateful-service): An example Terragrunt unit that provisions the EC2 ASG service with persistent state via integration with a MySQL database.
- [ecr-repository](/units/ecr-repository): An example Terragrunt unit that provisions an ECR repository.
- [ecs-fargate-stateful-service](/units/ecs-fargate-stateful-service): An example Terragrunt unit that provisions the ECS Fargate service with persistent state via integration with a MySQL database.
- [lambda-artifact-s3-bucket](/units/lambda-artifact-s3-bucket): An example Terragrunt unit that provisions an S3 bucket for Lambda artifacts.
- [lambda-decoupled-service](/units/lambda-decoupled-service): An example Terragrunt unit that provisions a decoupled Lambda service.
- [lambda-iam-role-to-dynamodb](/units/lambda-iam-role-to-dynamodb): An example Terragrunt unit that provisions an IAM role for Lambda to access DynamoDB.
- [lambda-stateful-service](/units/lambda-stateful-service): An example Terragrunt unit that provisions a stateful Lambda service with persistent state via integration with a DynamoDB table.
- [mysql](/units/mysql): An example Terragrunt unit that provisions a MySQL database using RDS.
- [sg](/units/sg): An example Terragrunt unit that provisions a security group.
- [sg-to-db-sg-rule](/units/sg-to-db-sg-rule): An example Terragrunt unit that provisions a security group rule for database access.
- [dynamodb-table](/units/dynamodb-table): An example Terragrunt unit that provisions a DynamoDB table.

### Terragrunt Stacks

- [ec2-asg-stateful-service](/stacks/ec2-asg-stateful-service): An example Terragrunt stack that provisions an EC2 ASG service with an Application Load Balancer (ALB) in front of it, and a MySQL database for state storage. This stack is intended to be provisioned multiple times across multiple environments.

## Consuming the infrastructure-catalog

There are three ways to consume the components in this repository:

1. Use the [catalog](https://terragrunt.gruntwork.io/docs/features/catalog/) command to scaffold the relevant Infrastructure-as-Code (IaC) for new infrastructure.
2. Use the [scaffold](https://terragrunt.gruntwork.io/docs/features/scaffold/) command to scaffold the relevant IaC for new infrastructure.
3. Manually author IaC to use the components in this repository.

### Using the catalog command

The `catalog` command is a simple, self-service feature that allows you to quickly scaffold new IaC for usage in your IaC estate.

To use a fork of this repository as a source for a Terragrunt catalog, simply add the following to the `root.hcl` file at the root of your Terragrunt project:

```hcl
catalog {
  urls = [
    "git::git@github.com:acme/terragrunt-infrastructure-catalog",
  ]
}
```

Where `github.com/acme/terragrunt-infrastructure-catalog` is the URL for the fork of this repository.

**Note**: The `git::git@github.com:` syntax is used to explicitly tell Terragrunt to use SSH when cloning the repository. This is likely what you'll need to do if you're using a private fork of this repository.

Once you've configured the catalog, you can create a new directory, navigate into it, and run `terragrunt catalog` to see the components available for scaffolding:

```bash
mkdir -p live/non-prod/us-east-1/my-lambda-service
cd live/non-prod/us-east-1/my-lambda-service
terragrunt catalog
```

This will present a list of components you can scaffold.

![Catalog](./docs/images/catalog.png)

You can search for a specific component using the `/` key, select it using the `Enter` key, and press the `S` key to scaffold it, which will create the relevant IaC for that component in the current directory.

At the time of writing, the catalog command only supports scaffolding modules as units. Support for more types of components are planned for the future.

For more information, see the [Terragrunt Catalog feature documentation](https://terragrunt.gruntwork.io/docs/features/catalog/).

### Using the scaffold command

The `catalog` command is most useful when browsing for infrastructure patterns, and you aren't sure exactly what you need to provision.

The `scaffold` command is a shortcut that allows you to scaffold an infrastructure pattern directly from the command line, without having to interact with the Terminal User Interface (TUI) of the `catalog` command.

To use the `scaffold` command, you can run the following command:

```bash
terragrunt scaffold <component>
```

For example, instead of running `terragrunt catalog` and then selecting the `lambda-service` component, you can run the following instead:

```bash
terragrunt scaffold git::git@github.com:acme/terragrunt-infrastructure-catalog//modules/lambda-service
```

**Note**: Take note of the double-slash (`//`) in the URL above. This is used to specify the relative path within the repository for the component you want to scaffold.

### Manually author IaC

You can also manually author IaC to use the components in this repository directly. You can see examples of this in the [examples](/examples) directory.

There are three patterns of IaC that you will find in the [examples](/examples) directory:

1. [Use OpenTofu modules directly](/examples/tofu). This is useful if you want to develop new [OpenTofu/Terraform modules](https://terragrunt.gruntwork.io/docs/getting-started/terminology/#module) in isolation, and are working out the right patterns and interfaces for your infrastructure patterns.

   We recommend keeping the majority of direct OpenTofu usage like this to the `examples/tofu` directory of this repository, as Terragrunt was designed to help you manage and scale IaC, and leveraging Terragrunt configurations are the best way to do this.

   Authoring OpenTofu/Terraform code in this repository is a good way to test out patterns and validate interfaces for your infrastructure patterns, before you start leveraging them in your Terragrunt units and stacks.

2. [Use Terragrunt Units](/examples/terragrunt/units). This is useful if you want to provision a particular infrastructure pattern one (or a few) time(s) using [Terragrunt units](https://terragrunt.gruntwork.io/docs/getting-started/terminology/#unit). Units are a way to provision OpenTofu/Terraform modules in a systematic way, so that they are reliably reproduced, with business logic and dependencies between them abstracted out of OpenTofu/Terraform code. This helps to keep your OpenTofu/Terraform code simple, generic and easier to maintain.

   Terragrunt units are a scalable way to provision OpenTofu/Terraform modules in production, so the examples in [examples/terragrunt/units](/examples/terragrunt/units) should be usable as-is in your own infrastructure estate in `infrastructure-live` repositories.

   Units are best used when scoped to solutions for individual point problems (e.g. a single database, a single service, etc.), so that they have a single responsibility, and are easy to reason about, operate and update in isolation.

3. [Use Terragrunt Stacks](/examples/terragrunt/stacks). This is useful if you want to provision multiple infrastructure patterns as a single entity in your infrastructure estate. [Terragrunt Stacks](https://terragrunt.gruntwork.io/docs/getting-started/terminology/#stack) are a way to provision multiple Terragrunt units in a systematic way, so that you can reliably reproduce collections of infrastructure across your organization. These are typically used to provision the same infrastructure across multiple environments (e.g. `dev`, `staging`, `prod`) in a way that is repeatable and easy to reason about, and are a great way to scale your infrastructure.

   Terragrunt stacks are a great way to provision collections of Terragrunt units as a single entity in your infrastructure estate, so they are typically used to provision full-fledged business solutions (e.g. a complete application, including the database that backs it, the service that runs the compute, etc.).

   Stacks are best used when you have established a repeatable pattern for how you want to provision collections of infrastructure patterns across your organization. They operate at a level of abstraction that is higher than that of units, and are a great way to scale your infrastructure once you have a proven pattern for how you want to deploy your infrastructure. If you're new to Terragrunt, you're generally advised to start with modules and units, and to only abstract out a collection of units into a stack once you have a proven pattern for how you want to deploy your infrastructure. If you're an experienced Terragrunt user, you may find it easier to define your infrastructure using stacks from the start.

## Development

This is a general guide for how you can update the components in this repository.

### Updating an OpenTofu/Terraform Module

1. `git clone` this repository.
2. Update the code as necessary in the [modules](/modules) directory.
3. Go to the [examples/tofu](/examples/tofu) directory and confirm that there's an example that corresponds to the usage of the module you just added support for.
4. Navigate to the example directory and run `tofu init && tofu plan`.
5. If the plan looks good, run `tofu apply`.
6. If the infrastructure works as expected, run `tofu destroy`.

### Testing the module update

Now that you've given the module a quick sanity check, you can update the appropriate [Terratest](https://terratest.gruntwork.io/) test in the [test/tofu](/test/tofu) directory to ensure that the module continues to work as expected in the future.

1. Navigate to the [test/tofu](/test/tofu) directory.
2. Run `go test -timeout 60m -count=1 -run Test<Something>` to run the test you just updated.

   Explanation of the command:

   - `go test`: Run the test as a standard [Golang test](https://pkg.go.dev/testing).
   - `-timeout 60m`: Give the test 60 minutes to complete (you can adjust this depending on the expected runtime of the test).
   - `-count=1`: Run the test exactly once (Golang tests are automatically opted out of caching when using the `-count` flag, so this is a simple way to ensure that caching doesn't result in false positives).
   - `-run Test<Something>`: Run the test named `Test<Something>`. If you'd like to run all tests in a directory, you can omit this flag, and if you'd like to run all tests recursively, you can pass `./...` as the final argument to `go test` instead.

3. If the test passes, you should be confident that the module works as expected.

### Testing the module as a Terragrunt unit

The Terratest library also supports testing Terragrunt configurations by adjusting the `TerraformBinary` field of the `terraform.Options` struct.

e.g.

```go
terraformOptions := &terraform.Options{
  TerraformDir:    "../../../examples/terragrunt/units/ec2-asg-service",
  TerraformBinary: "terragrunt",
}
```

The [examples/terragrunt/units](/examples/terragrunt/units) directory contains examples of Terragrunt usage to provision OpenTofu/Terraform modules as Terragrunt units.

You can run the Terratests for these examples in the same way as the module tests above.

e.g.

```bash
TG_BUCKET_PREFIX='acme-' go test -timeout 60m -count=1 -run Test<Something>
```

**Note**: The `TG_BUCKET_PREFIX` environment variable is used to set the prefix for the OpenTofu/Terraform state bucket as managed by Terragrunt's [Remote State Backend feature](https://terragrunt.gruntwork.io/docs/features/state-backend/). This is used to ensure that the Terragrunt state bucket is unique across all S3 buckets in existence. It's recommended to either set this environment variable to a short prefix that represents your organization (e.g. `acme-`), or to update the value in [examples/terragrunt/root.hcl](/examples/terragrunt/root.hcl) to hard-code a value unique to your organization for the `bucket` attribute.

Testing OpenTofu/Terraform modules as Terragrunt units is useful to ensure that the module can be reliably provisioned as a Terragrunt unit in the future. It can also be useful to validate that certain implementation details of how the module is meant to be consumed can be done reliably. For example, you may want to test that application code that a module depends on is packaged correctly by the [hooks](https://terragrunt.gruntwork.io/docs/features/hooks/) used in the unit, or that the right interface has been exposed for consumption by the unit.

### Updating Terragrunt units and stacks

The units found in the [units](/units) directory are intended to be used as part of a stack, referenced by `terragrunt.stack.hcl` files.

As such, you typically won't find the units in [units](/units) used directly in isolation in the [examples/terragrunt/units](/examples/terragrunt/units) directory. Instead, you'll find them used as part of a stack in the [examples/terragrunt/stacks](/examples/terragrunt/stacks) directory. You will also find collections of these units, leveraged in the [stacks](/stacks) directory, used in some of these examples.

The process for updating the units and stacks is the same as updating the modules.

1. Update the code as necessary in the [units](/units) and [stacks](/stacks) directories.
2. Update the examples in the [examples/terragrunt/stacks](/examples/terragrunt/stacks) directory to reflect the changes you made to them.
3. Navigate to the relevant example directory, and run the `terragrunt stack plan` and `terragrunt stack apply` commands to test the changes you made.
4. If the changes work as expected, you can run the `terragrunt stack destroy` command to clean up the infrastructure you just provisioned.
5. Like with modules, you can update the Terratests in the [test/terragrunt/stacks](/test/terragrunt/stacks) directory to ensure that the stack continues to work as expected in the future.

### Releasing a New Version

When you're done testing changes locally, the following steps are how you release a new version:

1. Update the code as necessary.
2. Commit your changes to Git: `git commit -m "commit message"`.
3. Create a new release. (e.g. on GitHub, go to the [releases page](/releases) and click "Draft a new release").
4. Now you can reference the new Git tag (e.g. `v0.0.2`) in the `ref` query string parameter of the `source` attribute in your `terragrunt.hcl` or `terragrunt.stack.hcl` file.

## Repository Structure

This repository uses the following folder structure:

- `modules/`: Contains reusable OpenTofu/Terraform modules
- `units/`: Contains Terragrunt units that provision OpenTofu/Terraform modules
- `stacks/`: Contains Terragrunt stacks that provision collections of Terragrunt units
- `examples/`: Contains example code showing how to use the modules, units, and stacks
- `test/`: Contains automated tests for the examples
- `.circleci/`: Contains CI/CD configuration
- `.pre-commit-config.yaml`: Contains pre-commit hook configurations

## Monorepo vs. Polyrepo

This repo is an example of a *monorepo*, where you have multiple modules, units and stacks in a single repository. There are benefits and drawbacks to using a monorepo vs. using a *polyrepo* - one module/unit/stack per repository. Which you choose depends on your tooling, how you build/test OpenTofu/Terraform modules, and so on. Regardless, the [live repo](https://github.com/gruntwork-io/terragrunt-infrastructure-live-example) will consume the components in the same way: a reference to a Git release tag in a `terragrunt.hcl`/`terragrunt.stack.hcl` file.

### Advantages of a Monorepo

- **Easier to make global changes across the entire codebase.** For example, applying a critical security fix or upgrading everything to a new version of Terraform/OpenTofu can happen in one logical commit.
- **Easier to search across the entire codebase.** You can search through all the module code using a standard text editor or file searching utility just with one repo checked out.
- **Simpler continuous integration across modules.** All your code is tested and versioned together. This reduces the chance of *late integration* - issues arising from out-of-date module-dependencies.
- **Single repo and build pipeline to manage.** Permissions, pull requests, etc. all happen in one spot. Everything validates and tests together so you can see any failures in one spot.

### Disadvantages of a Monorepo

- **Harder to keep changes isolated.** While you're modifying module `foo`, you also have to think through whether this will affect module `bar`.
- **Ever-increasing testing time.** The simple approach is to run all tests after every commit, but as the monorepo grows, this gets slower and slower (and more brittle).
- **No dependency management system.** To only run a subset of the tests or otherwise validate only changed components, you need a way to tell which components were affected by which commits.
- **No feature toggle support.** OpenTofu/Terraform don't support feature toggles, which are often critical for making large scale changes in a monorepo ([Terragrunt does](https://terragrunt.gruntwork.io/docs/features/runtime-control/#feature-flags), however).
- **Release versions change even if component code didn't change.** A new "release" of a monorepo involves tagging the repo with a new version. Even if only one component changed, all the components effectively get a new version. This can be especially problematic when introducing a breaking change, as it will require that consumption of any component be done more carefully, even if the component didn't change at all.

### Advantages of One-Repo-Per-Module

- **Easier to keep changes isolated.** You mostly only have to think about the one component/repo you're changing rather than how it affects other components.
- **Testing is faster and isolated.** When you run tests, it's just tests for this one component, so no extra tooling is necessary to keep tests fast.
- **Easier to detect individual component changes.** With only one component in a repo, there's no guessing at which component changed as releases are published.

### Disadvantages of One-Repo-Per-Module

- **Harder to make global changes.** Changes across repositories require lots of checkouts, separate commits and pull requests, and an updated release per module.
- **Harder to search across the codebase.** Searches require checking out all the repositories or having tooling (e.g., GitHub or Azure DevOps) that allows searching across repositories remotely.
- **No continuous integration across components.** You might make a change in your component, and the teams that depend on that component might not upgrade to the new version for a long time.
- **Many repositories and builds to manage.** Permissions, pull requests, build pipelines, test failures, etc. get managed in several places.
- **Potential dependency graph problems.** It is possible to run into issues like "diamond dependencies" when using many components together (See [Dependency Hell](https://en.wikipedia.org/wiki/Dependency_hell)).
- **Slower initialization.** OpenTofu/Terraform downloads each dependency from scratch, so if one repo depends on components from many other repos, it will download that component every time it's used rather than just once.
