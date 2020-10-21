variable "aws_profile" {
  description = "The AWS profile name; used as a prefix for Vault secrets"
  type = string
}

variable "lambda_artifact_key" {
    default = "data-lake/Archive1.zip"
    description = "The bucket key of the lambda artifact"
    type = string
}

variable "region" {
  description = "The AWS region in which resources will be administered"
  type = string
}

variable "release_bucket_name" {
    description = "The name of the release bucket"
    type = string
}

variable "service" {
  type        = string
  description = "The service name to be used when creating AWS resources"
  default     = "data-lake"
}
