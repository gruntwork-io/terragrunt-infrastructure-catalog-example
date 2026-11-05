//go:build gcp

package terragrunt_stacks_test

import "github.com/gruntwork-io/terragrunt-infrastructure-modules-example/internal/gcptest"

func init() {
	sweeps = append(sweeps, gcptest.Sweep)
}
