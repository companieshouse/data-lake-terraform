data "vault_generic_secret" "secrets" {
  path = "applications/${var.aws_profile}/${var.service}"
}

locals {
  bucket                                = data.vault_generic_secret.secrets.data.bucket
  database_password                     = data.vault_generic_secret.secrets.data.database_password
  database_username                     = data.vault_generic_secret.secrets.data.database_username
  glue_arguments                        = data.vault_generic_secret.secrets.data.glue_arguments
  glue_availability_zone                = data.vault_generic_secret.secrets.data.glue_availability_zone
  glue_script_location                  = data.vault_generic_secret.secrets.data.glue_script_location
  glue_subnet_id                        = data.vault_generic_secret.secrets.data.glue_subnet_id
  mongo_db_security_group_tag_filter    = data.vault_generic_secret.secrets.data.mongo_db_security_group_tag_filter
  mongo_export_collection               = data.vault_generic_secret.secrets.data.mongo_export_collection
  mongo_export_db_url                   = data.vault_generic_secret.secrets.data.mongo_export_db_url
  mongo_export_s3_path                  = data.vault_generic_secret.secrets.data.mongo_export_s3_path
  mongo_export_subnet_ids               = data.vault_generic_secret.secrets.data.mongo_export_subnet_ids

  # TODO - Pull this in from network state rather than vault
  vpc_id                                = data.vault_generic_secret.secrets.data.vpc_id
}
