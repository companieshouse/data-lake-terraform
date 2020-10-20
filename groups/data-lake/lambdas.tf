# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_lambda_function.mongo_export MongoEFSToS3Export
resource "aws_lambda_function" "mongo_export" {
  s3_bucket     = "${var.release_bucket_name}"
  s3_key        = "${var.lambda_artifact_key}"
  function_name = "MongoEFSToS3Export"
  handler       = "index.handler"
  role          = aws_iam_role.mongo_export.arn
  runtime       = "nodejs10.x"
  timeout       = 303

  vpc_config {
    subnet_ids         = split(",", local.mongo_export_subnet_ids)
    security_group_ids = [data.aws_security_group.mongo_db.id]
  }

  environment {
    variables = {
      COLLECTION = local.mongo_export_collection
      MONGO_URL = local.mongo_export_db_url
      S3_PATH   = "${aws_s3_bucket.data_lake.id}/${local.mongo_export_s3_path}"
    }
  }
}
