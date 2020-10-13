variable "aws_profile" {
  default = "development-eu-west-2"
  type = string
}

variable "region" {
    type = string
}

variable "vault_role_id" {
    description = "The Hashicorp Vault role id"
    type = string
}

variable "vault_secret_id" {
    description = "The Hashicorp Vault secret id"
    type = string
}
