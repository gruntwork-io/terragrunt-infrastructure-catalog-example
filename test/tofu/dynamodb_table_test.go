package tofu_test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestModuleDynamoDBTable(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir:    "../../examples/tofu/dynamodb-table",
		TerraformBinary: "tofu",
		Vars: map[string]interface{}{
			"name":          fmt.Sprintf("dynamodb-test-%s", random.UniqueId()),
			"hash_key":      "id",
			"hash_key_type": "S",
			"billing_mode":  "PAY_PER_REQUEST",
		},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)
}
