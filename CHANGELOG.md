# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the module
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Releases are cut automatically by `release-please` on merge to `main`,
driven by Conventional Commit prefixes (`feat:` → minor, `fix:`/`docs:`/`chore:` → patch,
`feat!:`/`BREAKING CHANGE:` → major).

## [Unreleased]

### Added

- Initial release: an AWS Lambda function with a least-privilege execution role
  (trusting `lambda.amazonaws.com`, `AWSLambdaBasicExecutionRole` attached, and
  `AWSLambdaVPCAccessExecutionRole` when `vpc_config` is set), an encrypted and
  retained CloudWatch log group (`/aws/lambda/<name>`, 30-day retention, optional
  KMS), Active X-Ray tracing, optional VPC config, environment variables, reserved
  concurrency, and `additional_policy_arns` for downstream access. Deployment
  artifact via `filename` or `s3_bucket`/`s3_key`. Native `label.tf` naming;
  derived from `cloudposse/terraform-aws-lambda-function`.
