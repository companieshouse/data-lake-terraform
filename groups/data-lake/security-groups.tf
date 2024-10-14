data "aws_security_group" "mongo_db" {
  filter {
    name = "tag:Name"
    values = [local.mongo_db_security_group_tag_filter]
  }
}

# terraform-runner -g data-lake -c apply -p development-eu-west-2 -- -target=aws_security_group.data
resource "aws_security_group" "data" {

  # TODO add suitable resource name and rule descriptions

  vpc_id = local.vpc_id

  ingress {
    description     = "Internal access from prefix list"
    from_port       = 5439
    to_port         = 5439
    protocol        = "tcp"
    prefix_list_ids = [var.admin_prefix_list_id]
  }

  ingress {
    description     = "Internal access from application CIDRs"
    from_port       = 5439
    to_port         = 5439
    protocol        = "tcp"
    cidr_blocks     = local.ingress_cidrs
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
    description     = "Internal access from prefix list"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    prefix_list_ids = ["${var.admin_prefix_list_id}"]
  }

  ingress {
    description     = "MySQL access from application CIDRs"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = local.ingress_cidrs
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
