package test

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformResourceGroup(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/resource_group",
	})

	// This is a minimal test that just runs terraform init
	terraform.Init(t, terraformOptions)
}
