# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_glue_catalog_database.data 169942020521:efs-mongo-extract
resource "aws_glue_catalog_database" "data" {
  name = local.glue_catalog_database
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_glue_crawler.data efs-mongo-extract-crawl
resource "aws_glue_crawler" "data" {
  database_name = aws_glue_catalog_database.data.name
  name          = "${local.glue_catalog_database}-crawl"
  role          = aws_iam_role.data_lake_glue.arn

  s3_target {
    path = "s3://${aws_s3_bucket.data_lake.id}/${local.mongo_export_s3_path}"
  }

  configuration = <<EOF
{
  "Version":1.0,
  "Grouping": {
    "TableGroupingPolicy": "CombineCompatibleSchemas"
  }
}
EOF
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_glue_connection.data 169942020521:redshift_newcluster
resource "aws_glue_connection" "data" {
  name = "redshift_newcluster"

  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:redshift://${aws_redshift_cluster.data.endpoint}/${aws_redshift_cluster.data.database_name}"
    PASSWORD            = local.redshift_database_password
    USERNAME            = local.redshift_database_username
  }

  physical_connection_requirements {
    availability_zone      = local.glue_availability_zone
    security_group_id_list = [aws_security_group.data.id]
    subnet_id              = local.glue_subnet_id
  }
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_glue_job.data redshift_load_from_s3_deletefirst_v2
resource "aws_glue_job" "data" {
  name              = "redshift_load_from_s3_deletefirst_v2"
  number_of_workers = 10
  role_arn          = aws_iam_role.data_lake_glue.arn
  worker_type       = "G.1X"

  connections = [aws_glue_connection.data.name]

  command {
    script_location = "s3://${local.glue_scripts_bucket_name}%{ if local.glue_scripts_bucket_path != "" }/${local.glue_scripts_bucket_path}%{ endif }/redshift_load_from_s3_deletefirst_v2"
  }

  default_arguments = {
    "--TempDir"             = "s3://${local.glue_temporary_bucket_name}%{ if local.glue_temporary_bucket_path != "" }/${local.glue_temporary_bucket_path}%{ endif }"
    "--job-bookmark-option" = "job-bookmark-disable"
    "--job-language"        = "python"
  }
}
