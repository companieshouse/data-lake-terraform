# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_s3_bucket.data_lake aws-glue-datalakepre-london
resource "aws_s3_bucket" "data_lake" {
  bucket = local.bucket
  acl    = "private"
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_s3_bucket.data_lake_glue_temporary aws-glue-temporary-169942020521-eu-west-2
resource "aws_s3_bucket" "data_lake_glue_temporary" {
  bucket = local.glue_temporary_bucket_name
  acl    = "private"
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_s3_bucket.data_lake_glue_scripts aws-glue-scripts-169942020521-eu-west-2
resource "aws_s3_bucket" "data_lake_glue_scripts" {
  bucket = local.glue_scripts_bucket_name
  acl    = "private"
}
