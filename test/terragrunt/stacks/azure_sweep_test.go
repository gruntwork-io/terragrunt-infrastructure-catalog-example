//go:build azure

package terragrunt_stacks_test

import "github.com/gruntwork-io/terragrunt-infrastructure-modules-example/internal/azuretest"

func init() {
	sweeps = append(sweeps, azuretest.Sweep)
}
