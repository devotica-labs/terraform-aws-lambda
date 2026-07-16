locals {
  # Function name defaults to the composed label id; an explicit
  # function_name overrides it.
  function_name = coalesce(var.function_name, local.id)

  # Execution role and log group are named off the function.
  role_name      = "${local.function_name}-role"
  log_group_name = "/aws/lambda/${local.function_name}"

  vpc_enabled = local.enabled && var.vpc_config != null

  # Managed execution-role policies. Every function gets basic execution (writes
  # to CloudWatch Logs); a VPC-attached function also gets VPC access (manages
  # the ENIs). Static arn:aws is fine — this nativized module targets the aws
  # partition and does not need to be partition-aware.
  managed_policy_arns = local.enabled ? concat(
    ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"],
    var.vpc_config != null ? ["arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"] : [],
  ) : []

  # Caller-supplied extra managed/customer policy ARNs, keyed for a stable map.
  additional_policy_arns = local.enabled ? { for arn in var.additional_policy_arns : arn => arn } : {}
}
