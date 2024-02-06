# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_redshift_subnet_group.data cluster-subnet-group-2
resource "aws_redshift_subnet_group" "data" {
  description = "Private subnet for redshift"
  name       = "cluster-subnet-group-2"
  subnet_ids = data.aws_subnet_ids.redshift_subnet.ids
}

# terraform-runner -g data-lake -c import -p development-eu-west-2 -- aws_redshift_cluster.data redshift-cluster-3
resource "aws_redshift_cluster" "data" {
  cluster_identifier = local.redshift_cluster_identifier
  master_password    = local.redshift_database_password
  master_username    = local.redshift_database_username
  node_type          = "dc2.large"

  publicly_accessible = false
  skip_final_snapshot = true
  encrypted           = true

  cluster_subnet_group_name = aws_redshift_subnet_group.data.name
  database_name = local.redshift_database_name

  automated_snapshot_retention_period = 7

  vpc_security_group_ids = [aws_security_group.data.id]

  logging {
    enable               = true
    log_destination_type = "cloudwatch"
    log_exports          = ["connectionlog", "userlog"]
  }

  depends_on = [
    aws_security_group.data
  ]

}
