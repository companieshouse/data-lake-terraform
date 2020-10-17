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
