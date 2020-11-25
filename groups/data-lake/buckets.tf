# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_s3_bucket.data_lake aws-glue-datalakepre-london
resource "aws_s3_bucket" "data_lake" {
  bucket = local.bucket_name
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "data_lake" {
  bucket = aws_s3_bucket.data_lake.id

  block_public_acls         = true
  block_public_policy       = true
  ignore_public_acls        = true
  restrict_public_buckets   = true
}

resource "aws_s3_bucket_object" "glue_scripts" {
  bucket = aws_s3_bucket.data_lake.id
  acl    = "private"
  key    = "${local.glue_scripts_bucket_path}/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "glue_temporary" {
  bucket = aws_s3_bucket.data_lake.id
  acl    = "private"
  key    = "${local.glue_temporary_bucket_path}/"
  source = "/dev/null"
}
