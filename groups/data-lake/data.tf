data "vault_generic_secret" "secrets" {
  path = "team-platform/${var.aws_profile}/${var.service}"
}

data "aws_subnets" "application_subnets" {
  filter {
    name   = "tag:NetworkType"
    values = ["private"]
  }
  tags = {
    Name = "platform-applications"
  }
}

data "aws_subnet" "application" {
  for_each = toset(data.aws_subnets.application_subnets.ids)

  id = each.value
}

data "aws_subnets" "data_subnets" {
  filter {
    name   = "tag:NetworkType"
    values = ["private"]
  }
  tags = {
    Name = "platform-data"
  }
}

data "aws_subnet" "data" {
  for_each = toset(data.aws_subnets.data_subnets.ids)
  id = each.value
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

data "aws_iam_policy_document" "data_lake_glue" {

  statement {

    sid = "ListAccessToDataLakeBucket"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "${data.aws_s3_bucket.data_lake.arn}"
    ]
  }

  statement {

    sid = "GetPutAccessToDataLakeBuckets"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${data.aws_s3_bucket.data_lake.arn}/*"
    ]
  }
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
      "${data.aws_s3_bucket.data_lake.arn}"
    ]
  }

  statement {

    sid = "WorkingAccessToDataLakeBucket"

    effect = "Allow"

    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "${data.aws_s3_bucket.data_lake.arn}/*"
    ]
  }
}

data "aws_security_group" "mongo_db" {
  filter {
    name = "tag:Name"
    values = [local.mongo_db_security_group_tag_filter]
  }
}

data "aws_subnet_ids" "redshift_subnet" {
  vpc_id = local.vpc_id

  filter {
    name = "tag:Name"
    values = [local.redshift_subnet_filter]
  }
}

data "aws_ec2_managed_prefix_list" "admin_prefix_list_id" {
  name = var.admin_prefix_list_name
}
