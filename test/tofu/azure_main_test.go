//go:build azure

package tofu_test

import (
	"os"
	"testing"

	"github.com/gruntwork-io/terragrunt-infrastructure-modules-example/internal/azuretest"
)

// TestMain deletes the resource groups that cancelled or crashed Azure test runs left behind, then runs the tests.
func TestMain(m *testing.M) {
	os.Exit(azuretest.RunTests(m))
}
