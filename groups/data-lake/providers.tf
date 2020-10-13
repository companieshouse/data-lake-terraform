provider "aws" {
  region = var.region
}

provider "vault" {
  auth_login {
    path = "auth/approle/login"

      parameters = {
        role_id   = var.vault_role_id
        secret_id = var.vault_secret_id
      }
    }
}
