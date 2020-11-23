# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_iam_role.data_lake_glue AWSGlueServiceRole-DataLakeGlue
resource "aws_iam_role" "data_lake_glue" {
  name = "AWSGlueServiceRole-DataLakeGlue"
  path = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.data_lake_glue_trust.json
}

data "aws_iam_policy_document" "data_lake_glue_trust" {
  statement {

    sid = "DataLakeTrustRole"

    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "glue.amazonaws.com"
      ]
    }
  }
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_iam_role_policy_attachment.glue_ec2_access AWSGlueServiceRole-DataLakeGlue/arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess
resource "aws_iam_role_policy_attachment" "glue_ec2_access" {
  role       = aws_iam_role.data_lake_glue.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_iam_role_policy_attachment.glue_iam_access AWSGlueServiceRole-DataLakeGlue/arn:aws:iam::aws:policy/IAMReadOnlyAccess
resource "aws_iam_role_policy_attachment" "glue_iam_access" {
  role       = aws_iam_role.data_lake_glue.name
  policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_iam_role_policy_attachment.glue_cloudwatch_access AWSGlueServiceRole-DataLakeGlue/arn:aws:iam::aws:policy/CloudWatchFullAccess
resource "aws_iam_role_policy_attachment" "glue_cloudwatch_access" {
  role       = aws_iam_role.data_lake_glue.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_iam_role_policy_attachment.glue_athena_access AWSGlueServiceRole-DataLakeGlue/arn:aws:iam::aws:policy/AmazonAthenaFullAccess
resource "aws_iam_role_policy_attachment" "glue_athena_access" {
  role       = aws_iam_role.data_lake_glue.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAthenaFullAccess"
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_iam_role_policy_attachment.glue_redshift_access AWSGlueServiceRole-DataLakeGlue/arn:aws:iam::aws:policy/AmazonRedshiftFullAccess
resource "aws_iam_role_policy_attachment" "glue_redshift_access" {
  role       = aws_iam_role.data_lake_glue.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftFullAccess"
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_iam_role_policy_attachment.glue_access AWSGlueServiceRole-DataLakeGlue/arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole
resource "aws_iam_role_policy_attachment" "glue_access" {
  role       = aws_iam_role.data_lake_glue.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_iam_policy.data_lake_glue arn:aws:iam::169942020521:policy/service-role/AWSGlueServiceRole-DataLakeGlue
resource "aws_iam_policy" "data_lake_glue" {
  name        = "AWSGlueServiceRole-DataLakeGlue"
  path        = "/service-role/"
  description = "This policy will be used for Glue Crawler and Job execution. Please do NOT delete!"

  policy = data.aws_iam_policy_document.data_lake_glue.json
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_iam_role_policy_attachment.data_lake_glue AWSGlueServiceRole-DataLakeGlue/arn:aws:iam::169942020521:policy/service-role/AWSGlueServiceRole-DataLakeGlue
resource "aws_iam_role_policy_attachment" "data_lake_glue" {
  role       = aws_iam_role.data_lake_glue.name
  policy_arn = aws_iam_policy.data_lake_glue.arn
}

data "aws_iam_policy_document" "data_lake_glue" {

  statement {

    sid = "ListAccessToDataLakeBuckets"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "${aws_s3_bucket.data_lake.arn}",
      "${aws_s3_bucket.data_lake_glue_temporary.arn}",
      "${aws_s3_bucket.data_lake_glue_scripts.arn}",
    ]
  }

  statement {

    sid = "GetPutAccessToDataLakeBuckets"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.data_lake.arn}/*",
      "${aws_s3_bucket.data_lake_glue_temporary.arn}/*",
      "${aws_s3_bucket.data_lake_glue_scripts.arn}/*"
    ]
  }
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_iam_role_policy.data_lake_data AWSGlueServiceRole-DataLakeGlue:DatalakeDataAccess
resource "aws_iam_role_policy" "data_lake_data" {
  name   = "DatalakeDataAccess"
  role   = aws_iam_role.data_lake_glue.name
  policy = data.aws_iam_policy_document.data_lake_data.json
}

data "aws_iam_policy_document" "data_lake_data" {
  statement {

    sid = "Lakeformation"

    actions = [
      "lakeformation:GetDataAccess",
      "lakeformation:GrantPermissions"
    ]

    resources = [
      "*"
    ]
  }
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_iam_role.mongo_export MongoEFSToS3Export-role-ubndlz9s
resource "aws_iam_role" "mongo_export" {
  name = "MongoEFSToS3Export-role-ubndlz9s"
  path = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.mongo_export_trust.json
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_iam_role_policy_attachment.vpc_access MongoEFSToS3Export-role-ubndlz9s/arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole
resource "aws_iam_role_policy_attachment" "vpc_access" {
  role       = aws_iam_role.mongo_export.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy_document" "mongo_export_trust" {
  statement {

    sid = "MongoExportTrustRole"

    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "mongo_export" {

  statement {

    sid = "ListAccessToDataLakeBucket"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "${aws_s3_bucket.data_lake.arn}"
    ]
  }

  statement {

    sid = "GetPutAccessToDataLakeBucket"

    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.data_lake.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "mongo_export" {
  name   = "DatalakeBucketAccess"
  policy = data.aws_iam_policy_document.mongo_export.json
}

resource "aws_iam_role_policy_attachment" "mongo_export" {
  role       = aws_iam_role.mongo_export.name
  policy_arn = aws_iam_policy.mongo_export.arn
}
