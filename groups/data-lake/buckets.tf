data "aws_s3_bucket" "data_lake" {
  bucket = local.bucket_name
}
