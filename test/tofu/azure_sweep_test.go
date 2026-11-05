//go:build azure

package tofu_test

import "github.com/gruntwork-io/terragrunt-infrastructure-modules-example/internal/azuretest"

func init() {
	sweeps = append(sweeps, azuretest.Sweep)
}
