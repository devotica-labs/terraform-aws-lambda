# Changelog

All notable changes to this module are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the module
follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Releases are cut automatically by `release-please` on merge to `main`,
driven by Conventional Commit prefixes (`feat:` → minor, `fix:`/`docs:`/`chore:` → patch,
`feat!:`/`BREAKING CHANGE:` → major).

## 0.1.0 (2026-07-16)


### Features

* **ci:** add architecture-diagram workflow + renderer ([9e1dd22](https://github.com/devotica-labs/terraform-aws-lambda/commit/9e1dd22bf23649ca1ad5e8f5aae9d74332914345))
* initial release of terraform-aws-lambda ([0b266fb](https://github.com/devotica-labs/terraform-aws-lambda/commit/0b266fb23f233abd6c8e5a0a260ee48e3cb41357))


### Bug Fixes

* **ci:** drop dead pip/scripts dependabot entry; tflint clean ([9c94bdc](https://github.com/devotica-labs/terraform-aws-lambda/commit/9c94bdc631e8cdf3c2e7bec0ade803449e5fafd5))
* **ci:** pass CI on terraform 1.9.5 ([45460df](https://github.com/devotica-labs/terraform-aws-lambda/commit/45460df1356bc423dead7fb3c6d76a669473d237))

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
