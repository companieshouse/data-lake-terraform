variable "aws_profile" {
  default = "development-eu-west-2"
  description = "The AWS profile name; used as a prefix for Vault secrets"
  type = string
}

variable "region" {
  description = "The AWS region in which resources will be administered"
  type = string
}

variable "service" {
  type        = string
  description = "The service name to be used when creating AWS resources"
  default     = "data-lake"
}
