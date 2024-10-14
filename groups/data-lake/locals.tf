locals {
  bucket_name                        = data.vault_generic_secret.secrets.data.bucket_name
  glue_availability_zone             = data.vault_generic_secret.secrets.data.glue_availability_zone
  glue_catalog_database              = data.vault_generic_secret.secrets.data.glue_catalog_database
  glue_scripts_bucket_path           = data.vault_generic_secret.secrets.data.glue_scripts_bucket_path
  glue_subnet_id                     = data.vault_generic_secret.secrets.data.glue_subnet_id
  glue_temporary_bucket_path         = data.vault_generic_secret.secrets.data.glue_temporary_bucket_path
  mongo_db_security_group_tag_filter = data.vault_generic_secret.secrets.data.mongo_db_security_group_tag_filter
  mongo_export_collection            = data.vault_generic_secret.secrets.data.mongo_export_collection
  mongo_export_db_url                = data.vault_generic_secret.secrets.data.mongo_export_db_url
  mongo_export_s3_path               = data.vault_generic_secret.secrets.data.mongo_export_s3_path
  mongo_export_subnet_ids            = data.vault_generic_secret.secrets.data.mongo_export_subnet_ids
  redshift_cluster_identifier        = data.vault_generic_secret.secrets.data.redshift_cluster_identifier
  redshift_database_name             = data.vault_generic_secret.secrets.data.redshift_database_name
  redshift_database_password         = data.vault_generic_secret.secrets.data.redshift_database_password
  redshift_database_username         = data.vault_generic_secret.secrets.data.redshift_database_username
  redshift_subnet_filter             = data.vault_generic_secret.secrets.data.redshift_subnet_filter
  application_subnet_ids             = join(",", data.aws_subnets.application_subnets.ids)
  application_subnet_cidrs           = [ for s in data.aws_subnet.application : s.cidr_block ]
  data_subnet_ids                    = join(",", data.aws_subnets.data_subnets.ids)
  data_subnet_cidrs                  = [ for s in data.aws_subnet.data : s.cidr_block ]
  ingress_cidrs                      = concat(local.application_subnet_cidrs, local.data_subnet_cidrs)
  admin_prefix_list_id               = data.aws_ec2_managed_prefix_list.admin_prefix_list_id.id

  # TODO - Pull this in from network state rather than vault
  vpc_id                                = data.vault_generic_secret.secrets.data.vpc_id
}
