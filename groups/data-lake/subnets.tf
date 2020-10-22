data "aws_subnet_ids" "redshift_subnet" {
  vpc_id = local.vpc_id

  filter {
    name = "tag:Name"
    values = [local.redshift_subnet_filter]
  }
}
