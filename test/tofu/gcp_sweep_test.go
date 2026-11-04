//go:build gcp

package tofu_test

import "github.com/gruntwork-io/terragrunt-infrastructure-modules-example/internal/gcptest"

func init() {
	sweeps = append(sweeps, gcptest.Sweep)
}
