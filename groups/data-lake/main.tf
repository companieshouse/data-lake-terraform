terraform {
  backend "s3" {
  }
}

data "aws_security_group" "mongo_db" {
  filter {
    name = "tag:Name"
    values = ["cidev-mongodb-dbs"]
  }
}

data "vault_generic_secret" "secrets" {
  path = "applications/${var.aws_profile}/data-lake"
}

locals {
  database_password = data.vault_generic_secret.secrets.data.database_password
  database_username = data.vault_generic_secret.secrets.data.database_username
  mongo_export_db_url = data.vault_generic_secret.secrets.data.mongo_export_db_url
  mongo_export_s3_path = data.vault_generic_secret.secrets.data.mongo_export_s3_path
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_lambda_function.mongo_export MongoEFSToS3Export
resource "aws_lambda_function" "mongo_export" {
  function_name = "MongoEFSToS3Export"
  handler       = "index.handler"
  role          = aws_iam_role.mongo_export.arn
  runtime       = "nodejs10.x"
  timeout       = 303

  # TODO replace hard-coded subnet identifier
  vpc_config {
    subnet_ids         = ["subnet-0c909ef698555c089"]
    security_group_ids = [data.aws_security_group.mongo_db.id]
  }

  environment {
    variables = {
      MONGO_URL = local.mongo_export_db_url
      S3_PATH   = "${aws_s3_bucket.data_lake.id}/${local.mongo_export_s3_path}"
    }
  }
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_s3_bucket.data_lake aws-glue-datalakepre-london
resource "aws_s3_bucket" "data_lake" {
  bucket = "aws-glue-datalakepre-london"
  acl    = "private"
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_redshift_cluster.data redshift-cluster-3
resource "aws_redshift_cluster" "data" {
  cluster_identifier = "redshift-cluster-3"
  master_password    = local.database_password
  master_username    = local.database_username
  node_type          = "dc2.large"

  publicly_accessible = false
  skip_final_snapshot = true

  database_name = "dev_top"

  vpc_security_group_ids = [aws_security_group.data.id]
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_glue_catalog_database.data 169942020521:efs-mongo-extract
resource "aws_glue_catalog_database" "data" {
  name = "efs-mongo-extract"
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_glue_crawler.data efs-mongo-extract-crawl
resource "aws_glue_crawler" "data" {
  database_name = aws_glue_catalog_database.data.name
  name          = "efs-mongo-extract-crawl"
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
    PASSWORD            = local.database_password
    USERNAME            = local.database_username
  }

  physical_connection_requirements {
    # TODO replace hard-coded availability zone and subnet identifier
    availability_zone      = "eu-west-2b"
    security_group_id_list = [aws_security_group.data.id]
    subnet_id              = "subnet-0c4fb394c9c33b698"
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
    # TODO replace hard-coded script location
    script_location = "s3://aws-glue-scripts-169942020521-eu-west-2/Paul_Forsyth/redshift_load_from_s3_deletefirst_v2"
  }

  default_arguments = {
    # TODO replace hard-coded argument values
    "--TempDir"             = "s3://aws-glue-temporary-169942020521-eu-west-2/Paul_Forsyth"
    "--job-bookmark-option" = "job-bookmark-disable"
    "--job-language"        = "python"
  }
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_iam_role.data_lake_glue AWSGlueServiceRole-DataLakeGlue
resource "aws_iam_role" "data_lake_glue" {
  name = "AWSGlueServiceRole-DataLakeGlue"
  path = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.data_lake_glue_trust.json
}

data "aws_iam_policy_document" "data_lake_glue_trust" {
  statement {

    # TODO add suitable sid argument

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

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_iam_role_policy_attachment.glue_s3_access AWSGlueServiceRole-DataLakeGlue/arn:aws:iam::aws:policy/AmazonS3FullAccess
resource "aws_iam_role_policy_attachment" "glue_s3_access" {
  role       = aws_iam_role.data_lake_glue.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_iam_role_policy_attachment.glue_ec2_access AWSGlueServiceRole-DataLakeGlue/arn:aws:iam::aws:policy/AmazonEC2FullAccess
resource "aws_iam_role_policy_attachment" "glue_ec2_access" {
  role       = aws_iam_role.data_lake_glue.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_iam_role_policy_attachment.glue_iam_access AWSGlueServiceRole-DataLakeGlue/arn:aws:iam::aws:policy/IAMFullAccess
resource "aws_iam_role_policy_attachment" "glue_iam_access" {
  role       = aws_iam_role.data_lake_glue.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
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

    # TODO add suitable sid argument

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::datalakepre*"
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

# terraform-runner -g data-lake -c apply -p development-eu-west-2 -- -target=aws_security_group.data
resource "aws_security_group" "data" {

  # TODO add suitable resource name and rule descriptions

  # TODO replace hard-coded VPC identifier
  vpc_id = "vpc-074ff55ed5182e144"

  ingress {
    description = "Internal access"
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Self-referencing security group rule for Glue connections as per: https://docs.aws.amazon.com/glue/latest/dg/setup-vpc-for-glue-access.html#:~:text=To%20enable%20AWS%20Glue%20to,not%20open%20to%20all%20networks.
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_iam_role.mongo_export MongoEFSToS3Export-role-ubndlz9s
resource "aws_iam_role" "mongo_export" {
  name = "MongoEFSToS3Export-role-ubndlz9s"
  path = "/service-role/"
  assume_role_policy = data.aws_iam_policy_document.mongo_export_trust.json
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_iam_role_policy_attachment.s3_access MongoEFSToS3Export-role-ubndlz9s/arn:aws:iam::aws:policy/AmazonS3FullAccess
resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.mongo_export.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_iam_role_policy_attachment.vpc_access MongoEFSToS3Export-role-ubndlz9s/arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole
resource "aws_iam_role_policy_attachment" "vpc_access" {
  role       = aws_iam_role.mongo_export.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "aws_iam_policy_document" "mongo_export_trust" {
  statement {

    # TODO add suitable sid argument

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
