//go:build azure || gcp

package terragrunt_stacks_test

import (
	"fmt"
	"os"
	"testing"
)

// sweeps delete what cancelled or crashed test runs left behind, one per cloud whose build tag is set.
var sweeps []func() error

func TestMain(m *testing.M) {
	for _, sweep := range sweeps {
		if err := sweep(); err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
	}

	os.Exit(m.Run())
}
