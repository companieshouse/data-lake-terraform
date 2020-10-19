data "vault_generic_secret" "secrets" {
  path = "applications/${var.aws_profile}/${var.service}"
}

locals {
  bucket                                = data.vault_generic_secret.secrets.data.bucket
  glue_availability_zone                = data.vault_generic_secret.secrets.data.glue_availability_zone
  glue_catalog_database                 = data.vault_generic_secret.secrets.data.glue_catalog_database
  glue_script_location                  = data.vault_generic_secret.secrets.data.glue_script_location
  glue_subnet_id                        = data.vault_generic_secret.secrets.data.glue_subnet_id
  glue_temporary_bucket_name            = data.vault_generic_secret.secrets.data.glue_temporary_bucket_name
  mongo_db_security_group_tag_filter    = data.vault_generic_secret.secrets.data.mongo_db_security_group_tag_filter
  mongo_export_collection               = data.vault_generic_secret.secrets.data.mongo_export_collection
  mongo_export_db_url                   = data.vault_generic_secret.secrets.data.mongo_export_db_url
  mongo_export_s3_path                  = data.vault_generic_secret.secrets.data.mongo_export_s3_path
  mongo_export_subnet_ids               = data.vault_generic_secret.secrets.data.mongo_export_subnet_ids
  redshift_database_password            = data.vault_generic_secret.secrets.data.redshift_database_password
  redshift_database_username            = data.vault_generic_secret.secrets.data.redshift_database_username

  # TODO - Pull this in from network state rather than vault
  vpc_id                                = data.vault_generic_secret.secrets.data.vpc_id
}
