package tofu_test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestModuleECRRepository(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir:    "../../examples/tofu/ecr-repository",
		TerraformBinary: "tofu",
		Vars: map[string]interface{}{
			"name":                 strings.ToLower(fmt.Sprintf("ecr-test-%s", random.UniqueId())),
			"image_tag_mutability": "MUTABLE",
			"force_delete":         true,
			"encryption_type":      "AES256",
			"scan_on_push":         true,
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
}
