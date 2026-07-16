plugin "aws" {
  enabled = true
  version = "0.30.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# tflint statically evaluates the function name with the label defaults
# (empty id), wrongly flagging an invalid name. Real usage supplies
# namespace/stage/name; AWS enforces the real constraint at apply.
rule "aws_lambda_function_invalid_function_name" { enabled = false }

rule "terraform_deprecated_interpolation" { enabled = true }
rule "terraform_documented_outputs"       { enabled = true }
rule "terraform_documented_variables"     { enabled = true }
rule "terraform_naming_convention"        { enabled = true }
rule "terraform_required_providers"       { enabled = true }
rule "terraform_required_version"         { enabled = true }
rule "terraform_typed_variables"          { enabled = true }
rule "terraform_unused_declarations"      { enabled = true }
